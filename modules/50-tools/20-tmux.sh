#!/bin/bash
# tmux Installation and Configuration Module
# Installs tmux and writes ~/.tmux.conf for all provisioned users

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

# All provisioned users — must match modules/20-users/
readonly PROVISIONED_USERS=("bryan" "dgxc" "openclaw" "amazeeio")

readonly TMUX_CONF_LINE="set -g mouse on"
readonly TMUX_CONF_COMMENT="# added by brybuntu-server provisioning"

# ============================================================================
# tmux Installation
# ============================================================================

# Check if a package is already installed
is_package_installed() {
    local package="$1"
    dpkg -l "$package" 2>/dev/null | grep -q "^ii"
}

# Install tmux if not already installed
install_tmux() {
    if is_package_installed "tmux"; then
        log_info "tmux already installed, skipping"
        return 0
    fi

    log_info "Installing tmux..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || die "Failed to update package list"
    apt-get install -y -qq tmux || die "Failed to install tmux"
    log_info "tmux installed successfully"
}

# ============================================================================
# tmux Configuration
# ============================================================================

# Write ~/.tmux.conf for a single user
# Usage: configure_tmux_for_user "username"
configure_tmux_for_user() {
    local username="$1"

    # Skip if user does not exist on this system
    if ! id "$username" &>/dev/null; then
        log_warn "User '$username' does not exist, skipping tmux config for this user"
        return 0
    fi

    local home_dir
    home_dir=$(getent passwd "$username" | cut -d: -f6)

    local tmux_conf="${home_dir}/.tmux.conf"

    # Idempotency: skip if the line is already present
    if [[ -f "$tmux_conf" ]] && grep -qF "$TMUX_CONF_LINE" "$tmux_conf"; then
        log_info "'$TMUX_CONF_LINE' already present in $tmux_conf for '$username', skipping"
        return 0
    fi

    log_info "Writing tmux mouse config for '$username'..."
    {
        echo ""
        echo "$TMUX_CONF_COMMENT"
        echo "$TMUX_CONF_LINE"
    } >> "$tmux_conf"

    chown "$username:$username" "$tmux_conf"
    log_info "tmux config written for '$username': $tmux_conf"
}

# Configure tmux for all provisioned users
configure_tmux() {
    log_info "Configuring tmux for all provisioned users..."

    for username in "${PROVISIONED_USERS[@]}"; do
        configure_tmux_for_user "$username"
    done

    log_info "tmux configuration complete for all provisioned users"
}

# ============================================================================
# Verification
# ============================================================================

verify_tmux() {
    log_info "Verifying tmux installation..."

    if ! command -v tmux &>/dev/null; then
        die "tmux not found in PATH after installation"
    fi

    log_info "tmux version: $(tmux -V)"
    log_info "Verification passed"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_tmux
    verify_tmux
    configure_tmux
    log_info "tmux setup complete"
}

main "$@"
