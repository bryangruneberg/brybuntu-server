#!/bin/bash
# Opencode Installation Module
# Installs Opencode CLI via npm

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Opencode Installation Functions
# ============================================================================

# Install Opencode CLI globally via npm
install_opencode() {
    log_info "Starting Opencode installation..."
    
    # Check if opencode is already installed
    if command -v opencode &>/dev/null; then
        local current_version
        current_version=$(opencode --version 2>/dev/null || echo "unknown")
        log_info "Opencode $current_version already installed, skipping"
        return 0
    fi
    
    # Ensure Node.js/npm is installed
    if ! command -v npm &>/dev/null; then
        die "npm is required but not installed. Run 10-node.sh first."
    fi
    
    # Install opencode globally
    log_info "Installing opencode via npm..."
    npm install -g opencode || die "Failed to install opencode"
    
    # Verify installation
    if command -v opencode &>/dev/null; then
        log_info "Opencode installed successfully"
    else
        die "Opencode installation verification failed"
    fi
    
    log_info "Opencode installation complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_opencode
}

main "$@"
