#!/bin/bash
# LazyVim Installation Module
# Installs LazyVim configuration for bryan and amazeeio users

set -euo pipefail

# Source libraries
source "$(dirname "$0")/../../lib/common.sh"
source "$(dirname "$0")/../../lib/dev.sh"

# ============================================================================
# LazyVim Installation
# ============================================================================

install_lazyvim() {
    log_info "Starting LazyVim installation..."
    
    # Check if git is installed (required for cloning)
    if ! command -v git &>/dev/null; then
        log_info "Installing git..."
        export DEBIAN_FRONTEND=noninteractive
        apt-get update -qq || true
        apt-get install -y -qq git || die "Failed to install git"
    fi
    
    # Check if Neovim is installed
    if ! command -v nvim &>/dev/null; then
        die "Neovim is required but not installed. Run 30-neovim.sh first."
    fi
    
    # Install LazyVim for bryan
    install_lazyvim_for_user "bryan"
    
    # Install LazyVim for amazeeio
    install_lazyvim_for_user "amazeeio"
    
    log_info "LazyVim installation complete for all users"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_lazyvim
}

main "$@"
