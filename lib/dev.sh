#!/bin/bash
# Brybuntu Server Setup - Development Environment Library
# Reusable functions for installing development tools per user

# Source guard: prevent double-sourcing
if [[ -n "${BRYBUNTU_DEV:-}" ]]; then
    return 0
fi
readonly BRYBUNTU_DEV=1

# Source common library
# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# ============================================================================
# LazyVim Installation Functions
# ============================================================================

# Install LazyVim for a specific user
# Usage: install_lazyvim_for_user "username"
# Returns: 0 on success, dies on failure
install_lazyvim_for_user() {
    local username="$1"
    
    # Check if user exists
    if ! id "$username" &>/dev/null; then
        die "User $username does not exist"
    fi
    
    # Get user's home directory
    local home_dir
    home_dir=$(getent passwd "$username" | cut -d: -f6)
    local nvim_config="$home_dir/.config/nvim"
    
    log_info "Installing LazyVim for user $username..."
    
    # Check if already installed
    if [[ -d "$nvim_config" ]]; then
        log_info "Neovim config already exists for $username, skipping LazyVim installation"
        return 0
    fi
    
    # Create .config directory if it doesn't exist
    local config_dir="$home_dir/.config"
    if [[ ! -d "$config_dir" ]]; then
        install -d -m 755 -o "$username" -g "$username" "$config_dir" || die "Failed to create .config directory for $username"
    fi
    
    # Clone LazyVim starter
    log_info "Cloning LazyVim starter configuration..."
    su - "$username" -c "git clone https://github.com/LazyVim/starter \"$nvim_config\"" || die "Failed to clone LazyVim starter for $username"
    
    # Remove the .git folder to make it user's own config
    rm -rf "$nvim_config/.git" || die "Failed to remove .git folder from LazyVim config"
    
    # Set proper ownership
    chown -R "$username:$username" "$nvim_config" || die "Failed to set ownership on LazyVim config"
    
    log_info "LazyVim installed for $username"
    log_info "Run 'nvim' as $username to complete setup"
    
    return 0
}
