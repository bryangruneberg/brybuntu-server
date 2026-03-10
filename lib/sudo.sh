#!/bin/bash
# Brybuntu Server Setup - Sudo Configuration Library
# Reusable functions for managing sudoers configuration with mandatory syntax validation

# Source guard: prevent double-sourcing
if [[ -n "${BRYBUNTU_SUDO:-}" ]]; then
    return 0
fi
readonly BRYBUNTU_SUDO=1

# Source common library
# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ============================================================================
# Sudoers Configuration Functions
# ============================================================================

# Validate a sudoers file using visudo
# Takes a file path as argument
# Returns: 0 if syntax is valid, 1 if invalid
# Usage: sudoers_validate "/path/to/sudoers/file"
sudoers_validate() {
    local file_path="$1"

    if [[ ! -f "$file_path" ]]; then
        log_error "Sudoers file not found: $file_path"
        return 1
    fi

    # Validate syntax using visudo -c
    # -c: check mode
    # -q: quiet (no output on success)
    # -f: specify file to check
    if visudo -c -q -f "$file_path" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Create a passwordless sudo rule for a user
# Validates syntax with visudo BEFORE installing to prevent root lockout
# Usage: sudoers_create_nopasswd "username"
# Returns: 0 on success, dies on failure
sudoers_create_nopasswd() {
    local username="$1"

    check_root

    # Verify user exists
    if ! id "$username" &>/dev/null; then
        die "User $username does not exist"
    fi

    local target_file="/etc/sudoers.d/$username"
    local rule="$username ALL=(ALL) NOPASSWD: ALL"

    # Idempotency: check if file already exists with correct content
    if [[ -f "$target_file" ]]; then
        local current_content
        current_content=$(cat "$target_file")
        if [[ "$current_content" == "$rule" ]]; then
            log_info "Sudoers config for $username already correct, skipping"
            return 0
        fi
    fi

    # Create temporary file for validation
    local temp_file
    temp_file=$(mktemp) || die "Failed to create temporary file"

    # Write rule to temporary file with newline
    printf '%s\n' "$rule" > "$temp_file" || die "Failed to write to temporary file"

    # CRITICAL: Validate syntax BEFORE installing
    # A syntax error in sudoers can lock out root access!
    if ! sudoers_validate "$temp_file"; then
        rm -f "$temp_file"
        die "Invalid sudoers syntax for $username - aborting to prevent root lockout"
    fi

    # Move to destination (atomic operation)
    mv "$temp_file" "$target_file" || die "Failed to install sudoers file for $username"

    # Set strict permissions (440 = owner read, group read, no write)
    chmod 440 "$target_file" || die "Failed to set permissions on sudoers file"
    chown root:root "$target_file" || die "Failed to set ownership on sudoers file"

    log_info "Created sudoers rule for $username"
    return 0
}
