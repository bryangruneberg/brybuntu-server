#!/bin/bash
# hadolint Installation Module
# Installs hadolint Dockerfile linter from GitHub releases

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# hadolint Installation Functions
# ============================================================================

# Install hadolint from GitHub releases
install_hadolint() {
    log_info "Starting hadolint installation..."

    # Idempotency check: skip if already installed
    if [[ -f /opt/hadolint/hadolint ]] && command -v hadolint &>/dev/null; then
        local current_version
        current_version=$(hadolint --version 2>/dev/null | head -1 || echo "installed")
        log_info "hadolint already installed: $current_version"
        return 0
    fi

    # Detect system architecture
    local arch
    arch=$(dpkg --print-architecture)

    local hadolint_arch
    case "$arch" in
        amd64)
            hadolint_arch="x86_64"
            ;;
        arm64)
            hadolint_arch="aarch64"
            ;;
        *)
            die "Unsupported architecture: $arch"
            ;;
    esac

    log_info "Detected architecture: $arch (using $hadolint_arch)"

    # Create installation directory
    log_info "Creating /opt/hadolint/ directory..."
    mkdir -p /opt/hadolint || die "Failed to create /opt/hadolint/ directory"

    # Download latest release from GitHub
    # Note: hadolint releases are single binaries (NOT tar.gz)
    local download_url
    download_url="https://github.com/hadolint/hadolint/releases/latest/download/hadolint-Linux-${hadolint_arch}"

    log_info "Downloading hadolint from GitHub releases..."
    log_info "URL: $download_url"

    curl -fsSL "$download_url" -o /opt/hadolint/hadolint || die "Failed to download hadolint"

    # Make binary executable
    chmod +x /opt/hadolint/hadolint || die "Failed to make hadolint executable"

    # Create symlink in /usr/local/bin/
    log_info "Creating symlink in /usr/local/bin/hadolint..."
    ln -sf /opt/hadolint/hadolint /usr/local/bin/hadolint || die "Failed to create symlink"

    # Verify installation
    log_info "Verifying hadolint installation..."
    if ! command -v hadolint &>/dev/null; then
        die "hadolint not found in PATH after installation"
    fi

    local hadolint_version
    hadolint_version=$(hadolint --version 2>/dev/null | head -1 || echo "unknown")
    log_info "hadolint installed successfully: $hadolint_version"

    log_info "hadolint installation complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_hadolint
}

main "$@"
