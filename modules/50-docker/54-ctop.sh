#!/bin/bash
# ctop Container Resource Monitor Installation Module
# Installs ctop for real-time Docker container resource monitoring
# Provides terminal-based view of CPU, memory, and resource usage

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# ctop Installation Functions
# ============================================================================

# Install ctop for container monitoring
install_ctop() {
    log_info "Starting ctop installation..."

    # Check if ctop is already installed
    if command -v ctop &>/dev/null; then
        local current_version
        current_version=$(ctop --version 2>/dev/null || echo "installed")
        log_info "ctop $current_version already installed, skipping"
        return 0
    fi

    # Check if ctop is already installed via dpkg
    if dpkg -l ctop 2>/dev/null | grep -q "^ii"; then
        log_info "ctop already installed via apt, skipping"
        return 0
    fi

    # Update apt package list
    log_info "Updating package list..."
    apt-get update -qq || die "Failed to update package list"

    # Check if ctop package is available in apt repositories
    log_info "Checking for ctop package availability..."
    if apt-cache show ctop &>/dev/null 2>&1; then
        # Install ctop via apt
        log_info "Installing ctop via apt..."
        export DEBIAN_FRONTEND=noninteractive
        apt-get install -y -qq ctop || die "Failed to install ctop"
    else
        # Fallback: Install ctop from GitHub release
        log_warn "ctop not available in apt repositories, installing from GitHub..."
        install_ctop_binary
    fi

    # Verify installation
    if command -v ctop &>/dev/null; then
        log_info "ctop installed successfully"
    else
        die "ctop installation verification failed"
    fi

    log_info "ctop installation complete"
}

# Install ctop binary from GitHub release (fallback method)
install_ctop_binary() {
    local ctop_url
    local arch
    local version="0.7.7"

    # Determine architecture
    arch=$(uname -m)
    case "$arch" in
        x86_64)
            arch="amd64"
            ;;
        aarch64|arm64)
            arch="arm64"
            ;;
        *)
            die "Unsupported architecture: $arch"
            ;;
    esac

    log_info "Downloading ctop binary for $arch..."
    ctop_url="https://github.com/bcicen/ctop/releases/download/v${version}/ctop-${version}-linux-${arch}"

    # Download to temporary location
    local temp_file
    temp_file=$(mktemp)
    curl -fsSL -o "$temp_file" "$ctop_url" || die "Failed to download ctop binary"

    # Install to /usr/local/bin
    log_info "Installing ctop to /usr/local/bin..."
    install -m 0755 "$temp_file" /usr/local/bin/ctop || die "Failed to install ctop binary"

    # Cleanup
    rm -f "$temp_file"

    # Verify binary works
    if ! ctop --version &>/dev/null 2>&1; then
        # Some versions use -v instead of --version
        if ! ctop -v &>/dev/null 2>&1; then
            # Verify it exists and is executable
            if [[ -x "/usr/local/bin/ctop" ]]; then
                log_info "ctop binary installed successfully"
            else
                die "ctop binary verification failed"
            fi
        fi
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_ctop
}

main "$@"
