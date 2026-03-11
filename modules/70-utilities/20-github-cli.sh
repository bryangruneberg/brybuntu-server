#!/bin/bash
# GitHub CLI (gh) Installation Module
# Installs the GitHub CLI tool using official repositories

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# GitHub CLI Installation Functions
# ============================================================================

install_github_cli() {
    log_info "Checking GitHub CLI installation..."
    
    # Check if gh is already installed
    if command -v gh &>/dev/null; then
        local current_version
        current_version=$(gh --version | head -n1)
        log_info "GitHub CLI already installed: $current_version"
        return 0
    fi
    
    log_info "Installing GitHub CLI (gh)..."
    
    # Install required dependencies
    log_info "Installing dependencies..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || die "Failed to update package list"
    apt-get install -y -qq curl gnupg ca-certificates || die "Failed to install dependencies"
    
    # Download GitHub CLI GPG key
    log_info "Adding GitHub CLI repository..."
    local keyring_file="/usr/share/keyrings/githubcli-archive-keyring.gpg"
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | \
        dd of="$keyring_file" status=none || die "Failed to download GitHub CLI GPG key"
    chmod go+r "$keyring_file"
    
    # Add GitHub CLI repository
    local arch
    arch=$(dpkg --print-architecture)
    echo "deb [arch=${arch} signed-by=${keyring_file}] https://cli.github.com/packages stable main" | \
        tee /etc/apt/sources.list.d/github-cli.list > /dev/null || die "Failed to add GitHub CLI repository"
    
    # Update package list and install gh
    log_info "Installing gh package..."
    apt-get update -qq || die "Failed to update package list"
    apt-get install -y -qq gh || die "Failed to install GitHub CLI"
    
    # Verify installation
    local installed_version
    installed_version=$(gh --version | head -n1)
    log_info "GitHub CLI installed: $installed_version"
    
    log_info "GitHub CLI installation complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_github_cli
}

main "$@"
