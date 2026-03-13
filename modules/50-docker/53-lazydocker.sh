#!/bin/bash
# lazydocker Installation Module
# Installs lazydocker TUI for interactive Docker container management

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# lazydocker Installation Functions
# ============================================================================

# Install lazydocker from GitHub releases
install_lazydocker() {
    log_info "Starting lazydocker installation..."

    # Idempotency check: skip if already installed
    if [[ -f /opt/lazydocker/lazydocker ]] && command -v lazydocker &>/dev/null; then
        local current_version
        current_version=$(lazydocker --version 2>/dev/null | head -1 || echo "installed")
        log_info "lazydocker already installed: $current_version"
        return 0
    fi

    # Detect system architecture
    local arch
    arch=$(dpkg --print-architecture)

    local lazydocker_arch
    case "$arch" in
        amd64)
            lazydocker_arch="x86_64"
            ;;
        arm64)
            lazydocker_arch="arm64"
            ;;
        *)
            die "Unsupported architecture: $arch"
            ;;
    esac

    log_info "Detected architecture: $arch (using $lazydocker_arch)"

    # Create installation directory
    log_info "Creating /opt/lazydocker/ directory..."
    mkdir -p /opt/lazydocker || die "Failed to create /opt/lazydocker/ directory"

    # Query GitHub API to get the latest release version
    log_info "Querying GitHub API for latest lazydocker version..."
    local latest_version
    latest_version=$(curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')

    if [[ -z "$latest_version" ]]; then
        die "Failed to determine latest lazydocker version from GitHub API"
    fi

    log_info "Latest lazydocker version: v${latest_version}"

    # Download latest release from GitHub
    local download_url
    download_url="https://github.com/jesseduffield/lazydocker/releases/download/v${latest_version}/lazydocker_${latest_version}_Linux_${lazydocker_arch}.tar.gz"

    # Validate the download URL exists before attempting download
    log_info "Validating download URL..."
    if ! curl -fsSLI "$download_url" -o /dev/null 2>&1; then
        die "Download URL validation failed: $download_url"
    fi

    local temp_dir
    temp_dir=$(mktemp -d)
    local tar_file="${temp_dir}/lazydocker.tar.gz"

    log_info "Downloading lazydocker from GitHub releases..."
    log_info "URL: $download_url"

    curl -fsSL "$download_url" -o "$tar_file" || die "Failed to download lazydocker from $download_url"

    # Extract tar.gz to /opt/lazydocker/
    log_info "Extracting lazydocker to /opt/lazydocker/..."
    tar -xzf "$tar_file" -C /opt/lazydocker lazydocker || die "Failed to extract lazydocker"

    # Clean up temp directory
    rm -rf "$temp_dir"

    # Verify binary exists
    if [[ ! -f /opt/lazydocker/lazydocker ]]; then
        die "lazydocker binary not found after extraction"
    fi

    # Make binary executable
    chmod +x /opt/lazydocker/lazydocker || die "Failed to make lazydocker executable"

    # Create symlink in /usr/local/bin/
    log_info "Creating symlink in /usr/local/bin/lazydocker..."
    ln -sf /opt/lazydocker/lazydocker /usr/local/bin/lazydocker || die "Failed to create symlink"

    # Verify installation
    log_info "Verifying lazydocker installation..."
    if ! command -v lazydocker &>/dev/null; then
        die "lazydocker not found in PATH after installation"
    fi

    local lazydocker_version
    lazydocker_version=$(lazydocker --version 2>/dev/null | head -1 || echo "unknown")
    log_info "lazydocker installed successfully: $lazydocker_version"

    log_info "lazydocker installation complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_lazydocker
}

main "$@"
