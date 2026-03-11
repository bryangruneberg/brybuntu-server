#!/bin/bash
# Opencode Installation Module
# Installs Opencode CLI via direct binary download from GitHub releases

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

readonly OPENCODE_INSTALL_DIR="/usr/local/bin"
readonly OPENCODE_BIN="${OPENCODE_INSTALL_DIR}/opencode"

# ============================================================================
# Opencode Installation Functions
# ============================================================================

# Detect architecture and OS for binary download
detect_target() {
    local arch
    arch=$(uname -m)
    
    # Map architecture names
    case "$arch" in
        x86_64) arch="x64" ;;
        aarch64) arch="arm64" ;;
        *) die "Unsupported architecture: $arch" ;;
    esac
    
    # Check for AVX2 support (for baseline build)
    local target="linux-${arch}"
    if [[ "$arch" == "x64" ]] && ! grep -qwi avx2 /proc/cpuinfo 2>/dev/null; then
        target="linux-${arch}-baseline"
    fi
    
    echo "$target"
}

# Get latest release version from GitHub
get_latest_version() {
    curl -s https://api.github.com/repos/anomalyco/opencode/releases/latest | \
        sed -n 's/.*"tag_name": *"v\([^"]*\)".*/\1/p'
}

# Install Opencode CLI via direct binary download
install_opencode() {
    log_info "Starting Opencode installation..."
    
    # Check if opencode is already installed
    if command -v opencode &>/dev/null; then
        local current_version
        current_version=$(opencode --version 2>/dev/null || echo "unknown")
        log_info "Opencode $current_version already installed, skipping"
        return 0
    fi
    
    # Install dependencies
    log_info "Installing dependencies..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || true
    apt-get install -y -qq curl tar || die "Failed to install dependencies"
    
    # Detect target platform
    local target
    target=$(detect_target)
    log_info "Detected target: $target"
    
    # Get latest version
    local version
    version=$(get_latest_version)
    if [[ -z "$version" ]]; then
        die "Failed to get latest Opencode version"
    fi
    log_info "Latest version: $version"
    
    # Download URL
    local filename="opencode-${target}.tar.gz"
    local url="https://github.com/anomalyco/opencode/releases/download/v${version}/${filename}"
    
    # Download and extract
    log_info "Downloading Opencode..."
    local tmp_dir
    tmp_dir=$(mktemp -d)
    trap "rm -rf '$tmp_dir'" EXIT
    
    curl -fsSL "$url" -o "${tmp_dir}/${filename}" || die "Failed to download Opencode"
    
    log_info "Extracting..."
    tar -xzf "${tmp_dir}/${filename}" -C "$tmp_dir" || die "Failed to extract Opencode"
    
    # Move binary to install location
    log_info "Installing to $OPENCODE_INSTALL_DIR..."
    mv "${tmp_dir}/opencode" "$OPENCODE_BIN" || die "Failed to install opencode binary"
    chmod 755 "$OPENCODE_BIN" || die "Failed to set permissions"
    
    # Verify installation
    if command -v opencode &>/dev/null; then
        local installed_version
        installed_version=$(opencode --version 2>/dev/null || echo "unknown")
        log_info "Opencode $installed_version installed successfully"
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
