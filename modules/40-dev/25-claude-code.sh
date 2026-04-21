#!/bin/bash
# Claude Code Installation Module
# Installs Claude Code CLI via official installer script

set -euo pipefail

source "$(dirname "$0")/../../lib/common.sh"

install_claude_code() {
    log_info "Starting Claude Code installation..."

    # Idempotency: skip if already installed
    if command -v claude &>/dev/null; then
        local current_version
        current_version=$(claude --version 2>/dev/null || echo "unknown")
        log_info "Claude Code $current_version already installed, skipping"
        return 0
    fi

    # Defensive dependency check: Node.js and npm required by install.sh
    if ! command -v node &>/dev/null; then
        die "Node.js is required but not installed. Run 10-node.sh first."
    fi
    if ! command -v npm &>/dev/null; then
        die "npm is required but not installed. Run 10-node.sh first."
    fi

    # Ensure curl is available
    log_info "Installing dependencies..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || true
    apt-get install -y -qq curl || die "Failed to install curl"

    # Run official Claude Code installer
    log_info "Running official Claude Code installer..."
    curl -fsSL https://claude.ai/install.sh | bash || die "Failed to install Claude Code"

    # Verify installation
    if command -v claude &>/dev/null; then
        local installed_version
        installed_version=$(claude --version 2>/dev/null || echo "unknown")
        log_info "Claude Code $installed_version installed successfully"
    else
        die "Claude Code installation verification failed"
    fi

    log_info "Claude Code installation complete"
}

main() {
    check_root
    install_claude_code
}

main "$@"
