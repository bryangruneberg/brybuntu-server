#!/bin/bash
# Node.js Installation Module
# Installs Node.js LTS via NodeSource repository

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Node.js Installation Functions
# ============================================================================

# Install Node.js LTS using NodeSource setup script
install_nodejs() {
    log_info "Starting Node.js installation..."
    
    # Check if Node.js is already installed and get version
    if command -v node &>/dev/null; then
        local current_version
        current_version=$(node --version)
        log_info "Node.js $current_version already installed, skipping"
        return 0
    fi
    
    # Install required dependencies for NodeSource script
    log_info "Installing dependencies..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || die "Failed to update package list"
    apt-get install -y -qq curl ca-certificates gnupg || die "Failed to install dependencies"
    
    # Download and run NodeSource setup script for Node.js LTS
    log_info "Setting up NodeSource repository..."
    curl -fsSL https://deb.nodesource.com/setup_lts.x | bash - || die "Failed to setup NodeSource repository"
    
    # Install Node.js
    log_info "Installing Node.js LTS..."
    apt-get install -y -qq nodejs || die "Failed to install Node.js"
    
    # Verify installation
    local node_version npm_version
    node_version=$(node --version)
    npm_version=$(npm --version)
    log_info "Node.js $node_version installed successfully"
    log_info "npm $npm_version installed successfully"
    
    log_info "Node.js installation complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_nodejs
}

main "$@"
