#!/bin/bash
# Laravel Installer Module
# Installs laravel/installer via `composer global require` for all provisioned users
# Requires: PHP 8.3 CLI and Composer (50-php-cli.sh must run first)

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

# All provisioned users — must match modules/20-users/
readonly PROVISIONED_USERS=("bryan" "dgxc" "openclaw" "amazeeio")

# ============================================================================
# Laravel Installer Functions
# ============================================================================

# Install laravel/installer for a single user via composer global require
# Usage: install_laravel_for_user "username"
install_laravel_for_user() {
    local username="$1"

    # Skip if user does not exist on this system
    if ! id "$username" &>/dev/null; then
        log_warn "User '$username' does not exist, skipping Laravel installer for this user"
        return 0
    fi

    local home_dir
    home_dir=$(getent passwd "$username" | cut -d: -f6)

    # Idempotency: check both Composer 1.x (~/.composer) and Composer 2.x (~/.config/composer) paths
    if [[ -f "${home_dir}/.composer/vendor/bin/laravel" ]] || \
       [[ -f "${home_dir}/.config/composer/vendor/bin/laravel" ]]; then
        log_info "Laravel installer already present for '$username', skipping"
        return 0
    fi

    log_info "Installing laravel/installer for '$username'..."
    su - "$username" -c "composer global require laravel/installer --no-interaction --quiet" \
        || die "Failed to install laravel/installer for '$username'"

    # Determine the actual composer global bin directory for this user
    local composer_bin_dir
    composer_bin_dir=$(su - "$username" -c "composer global config bin-dir --absolute 2>/dev/null" | tail -1) \
        || die "Failed to determine composer global bin-dir for '$username'"

    # Add composer global bin dir to user's PATH in ~/.profile if not already present
    local profile_file="${home_dir}/.profile"
    local path_export="export PATH=\"${composer_bin_dir}:\$PATH\""

    if [[ -f "$profile_file" ]] && grep -qF "$composer_bin_dir" "$profile_file"; then
        log_info "Composer bin dir already in PATH for '$username', skipping .profile update"
    else
        log_info "Adding composer bin dir to PATH for '$username'..."
        echo "" >> "$profile_file"
        echo "# Laravel installer (added by brybuntu-server provisioning)" >> "$profile_file"
        echo "$path_export" >> "$profile_file"
    fi

    log_info "Laravel installer installed for '$username' (bin: ${composer_bin_dir})"
}

# Install laravel/installer for all provisioned users
install_laravel_installer() {
    log_info "Starting Laravel installer setup for all provisioned users..."

    # Verify Composer is available (50-php-cli.sh must have run first)
    command -v composer &>/dev/null || die "Composer not found — run 50-php-cli.sh first"

    for username in "${PROVISIONED_USERS[@]}"; do
        install_laravel_for_user "$username"
    done

    log_info "Laravel installer setup complete for all provisioned users"
}

# ============================================================================
# Verification
# ============================================================================

verify_laravel_installer() {
    log_info "Verifying Laravel installer for provisioned users..."

    local verified=0
    local skipped=0

    for username in "${PROVISIONED_USERS[@]}"; do
        if ! id "$username" &>/dev/null; then
            log_warn "User '$username' does not exist, skipping verification"
            (( skipped++ )) || true
            continue
        fi

        local home_dir
        home_dir=$(getent passwd "$username" | cut -d: -f6)

        if [[ -f "${home_dir}/.composer/vendor/bin/laravel" ]] || \
           [[ -f "${home_dir}/.config/composer/vendor/bin/laravel" ]]; then
            log_info "Laravel installer verified for '$username'"
            (( verified++ )) || true
        else
            die "Laravel installer binary not found for '$username' after installation"
        fi
    done

    log_info "Laravel installer verification complete: ${verified} installed, ${skipped} skipped (user not found)"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_laravel_installer
    verify_laravel_installer
    log_info "Laravel installer module complete"
}

main "$@"
