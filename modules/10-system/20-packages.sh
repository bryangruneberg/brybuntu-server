#!/bin/bash
# Package Installation Module
# Installs system packages idempotently

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Package Installation Functions
# ============================================================================

# Install a package if not already present
# Args: $1 = package name
# Dies if installation fails
install_package() {
    local pkg="$1"
    
    if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
        log_info "$pkg already installed, skipping"
        return 0
    fi
    
    log_info "Installing $pkg..."
    apt-get install -y -qq "$pkg" || die "Failed to install $pkg"
}

# Install all required system packages
install_packages() {
    log_info "Starting package installation..."
    
    export DEBIAN_FRONTEND=noninteractive
    
    # Install kitty-terminfo for proper terminal support
    install_package "kitty-terminfo"
    
    log_info "Package installation complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_packages
}

main "$@"
