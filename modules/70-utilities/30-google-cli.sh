#!/bin/bash
# Google Workspace CLI Installation Module
# Installs @googleworkspace/cli via npm

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Google CLI Installation Functions
# ============================================================================

install_google_cli() {
    log_info "Checking Google Workspace CLI installation..."
    
    # Check if gws (Google Workspace CLI) is already installed
    if command -v gws &>/dev/null; then
        local current_version
        current_version=$(gws --version 2>/dev/null || echo "version info not available")
        log_info "Google Workspace CLI already installed: $current_version"
        return 0
    fi
    
    # Verify npm is available
    if ! command -v npm &>/dev/null; then
        die "npm not found. Node.js must be installed first (modules/40-dev/10-node.sh)"
    fi
    
    log_info "Installing Google Workspace CLI (@googleworkspace/cli)..."
    
    # Install globally via npm
    npm install -g @googleworkspace/cli || die "Failed to install @googleworkspace/cli"
    
    # Verify installation
    log_info "Verifying installation..."
    if command -v gws &>/dev/null; then
        log_info "Google Workspace CLI installed successfully"
        gws --version 2>/dev/null || log_info "Version check not available, but gws command works"
    else
        die "gws command not found after installation"
    fi
    
    log_info "Google Workspace CLI installation complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_google_cli
}

main "$@"
