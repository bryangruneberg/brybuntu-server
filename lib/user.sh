#!/bin/bash
# Brybuntu Server Setup - User Management Library
# Reusable functions for creating users with SSH key access

# Source guard: prevent double-sourcing
if [[ -n "${BRYBUNTU_USER:-}" ]]; then
    return 0
fi
readonly BRYBUNTU_USER=1

# Source common library
# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ============================================================================
# User Creation Functions
# ============================================================================

# Create a user with SSH key access and random password
# Usage: user_create_with_ssh "username" "ssh_public_key"
# Returns: 0 on success, dies on failure
user_create_with_ssh() {
    local username="$1"
    local ssh_key="$2"

    check_root

    # Idempotency: check if user already exists
    if id "$username" &>/dev/null; then
        log_info "User $username already exists, skipping creation"
    else
        # Create user with adduser (interactive, handles home dir)
        adduser --gecos "" --disabled-password "$username" || die "Failed to create user $username"
        log_info "Created user $username"
    fi

    # Generate random password
    local password
    password=$(openssl rand -base64 32) || die "Failed to generate password for $username"

    # Set password non-interactively
    echo "$username:$password" | chpasswd || die "Failed to set password for $username"

    # Display password to operator (critical: stdout only, don't log)
    printf '\n%s\n' "========================================"
    printf 'Password for %s: %s\n' "$username" "$password"
    printf '%s\n\n' "========================================"

    # Get home directory
    local home_dir
    home_dir=$(getent passwd "$username" | cut -d: -f6)

    local ssh_dir="$home_dir/.ssh"
    local auth_keys="$ssh_dir/authorized_keys"

    # Create .ssh directory with 700 permissions using install
    install -d -m 700 -o "$username" -g "$username" "$ssh_dir" 2>/dev/null || true

    # Add SSH key if not already present (check-before-append idempotency)
    if [[ ! -f "$auth_keys" ]] || ! grep -qF "$ssh_key" "$auth_keys"; then
        echo "$ssh_key" >> "$auth_keys" || die "Failed to add SSH key for $username"
        chmod 600 "$auth_keys" || die "Failed to set permissions on authorized_keys"
        chown "$username:$username" "$auth_keys" || die "Failed to set ownership on authorized_keys"
        log_info "Added SSH key for $username"
    else
        log_info "SSH key already present for $username, skipping"
    fi

    return 0
}
