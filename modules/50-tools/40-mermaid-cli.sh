#!/bin/bash
# Mermaid CLI Installation Module
# Installs: @mermaid-js/mermaid-cli globally via npm

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Mermaid CLI Installation Functions
# ============================================================================

# Check if mmdc is already installed
is_mmdc_installed() {
    command -v mmdc &>/dev/null
}

# Check if npm is available
check_npm() {
    if ! command -v npm &>/dev/null; then
        die "npm not found. Please install Node.js first."
    fi
    log_info "npm found: $(npm --version)"
}

# Install mermaid-cli globally
install_mermaid_cli() {
    log_info "Starting Mermaid CLI installation..."

    if is_mmdc_installed; then
        log_info "Mermaid CLI (mmdc) already installed, skipping"
        return 0
    fi

    log_info "Installing @mermaid-js/mermaid-cli globally..."
    npm install -g @mermaid-js/mermaid-cli || die "Failed to install @mermaid-js/mermaid-cli"
    log_info "Mermaid CLI installed successfully"
}

# Verify installation
verify_installation() {
    log_info "Verifying Mermaid CLI installation..."

    if ! command -v mmdc &>/dev/null; then
        die "mmdc command not found after installation"
    fi

    # Show version
    log_info "Mermaid CLI version: $(mmdc --version)"

    log_info "Mermaid CLI verification passed"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    check_npm
    install_mermaid_cli
    verify_installation
    log_info "Mermaid CLI installation complete"
}

main "$@"
