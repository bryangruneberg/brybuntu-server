#!/bin/bash
# dive Docker Image Analyzer Installation Module
# Installs dive for analyzing Docker image layers and optimizing image sizes

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# dive Installation Functions
# ============================================================================

# Install dive from GitHub releases
install_dive() {
    log_info "Starting dive installation..."

    # Idempotency check: skip if already installed
    if [[ -f /opt/dive/dive ]] && command -v dive &>/dev/null; then
        local current_version
        current_version=$(dive --version 2>/dev/null || echo "installed")
        log_info "dive already installed: $current_version"
        return 0
    fi

    # Detect system architecture
    local arch
    arch=$(dpkg --print-architecture)

    local dive_arch
    case "$arch" in
        amd64)
            dive_arch="x86_64"
            ;;
        arm64)
            dive_arch="aarch64"
            ;;
        *)
            die "Unsupported architecture: $arch"
            ;;
    esac

    log_info "Detected architecture: $arch (using $dive_arch)"

    # Create installation directory
    log_info "Creating /opt/dive/ directory..."
    mkdir -p /opt/dive || die "Failed to create /opt/dive/ directory"

    # Query GitHub API to get the latest release version
    log_info "Querying GitHub API for latest dive version..."
    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/wagoodman/dive/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')

    if [[ -z "$latest_version" ]]; then
        die "Failed to determine latest dive version from GitHub API"
    fi

    log_info "Latest dive version: v${latest_version}"

    # Download latest release from GitHub
    local download_url
    download_url="https://github.com/wagoodman/dive/releases/download/v${latest_version}/dive_${latest_version}_Linux_${dive_arch}.tar.gz"

    # Validate the download URL exists before attempting download
    log_info "Validating download URL..."
    if ! curl -fsSLI "$download_url" -o /dev/null 2>&1; then
        die "Download URL validation failed: $download_url"
    fi

    local temp_dir
    temp_dir=$(mktemp -d)
    local tar_file="${temp_dir}/dive.tar.gz"

    log_info "Downloading dive from GitHub releases..."
    log_info "URL: $download_url"

    curl -fsSL "$download_url" -o "$tar_file" || die "Failed to download dive"

    # Extract tar.gz to /opt/dive/
    log_info "Extracting dive to /opt/dive/..."
    tar -xzf "$tar_file" -C /opt/dive dive || die "Failed to extract dive"

    # Clean up temp directory
    rm -rf "$temp_dir"

    # Verify binary exists
    if [[ ! -f /opt/dive/dive ]]; then
        die "dive binary not found after extraction"
    fi

    # Make binary executable
    chmod +x /opt/dive/dive || die "Failed to make dive executable"

    # Create symlink in /usr/local/bin/
    log_info "Creating symlink in /usr/local/bin/dive..."
    ln -sf /opt/dive/dive /usr/local/bin/dive || die "Failed to create symlink"

    # Verify installation
    log_info "Verifying dive installation..."
    if ! command -v dive &>/dev/null; then
        die "dive not found in PATH after installation"
    fi

    local dive_version
    dive_version=$(dive --version 2>/dev/null || echo "unknown")
    log_info "dive installed successfully: $dive_version"

    log_info "dive installation complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_dive
}

main "$@"
