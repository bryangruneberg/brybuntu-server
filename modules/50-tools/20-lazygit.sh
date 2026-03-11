#!/bin/bash
# Lazygit Installation Module
# Installs lazygit from GitHub releases

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Lazygit Installation Functions
# ============================================================================

readonly LAZYGIT_BIN="/usr/local/bin/lazygit"
readonly TEMP_DIR="/tmp/lazygit-install"

# Install required dependencies (curl and tar)
install_dependencies() {
    log_info "Installing dependencies..."
    
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || true
    
    local deps=("curl" "tar")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            log_info "Installing $dep..."
            apt-get install -y -qq "$dep" || die "Failed to install $dep"
        fi
    done
    
    log_info "Dependencies installed"
}

# Get the latest lazygit version from GitHub API
get_latest_version() {
    log_info "Fetching latest lazygit version..."
    
    local version
    version=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*') || die "Failed to fetch latest version"
    
    if [[ -z "$version" ]]; then
        die "Could not determine latest lazygit version"
    fi
    
    echo "$version"
}

# Download and install lazygit
install_lazygit() {
    log_info "Installing lazygit..."
    
    # Check if already installed
    if command -v lazygit &>/dev/null; then
        local current_version
        current_version=$(lazygit --version 2>/dev/null | head -1 | grep -oP 'version=\K[^,]+' || echo "unknown")
        log_info "lazygit $current_version already installed"
        
        # Optionally could check for updates here, but we'll skip for now
        return 0
    fi
    
    # Create temp directory
    rm -rf "$TEMP_DIR"
    mkdir -p "$TEMP_DIR" || die "Failed to create temp directory"
    cd "$TEMP_DIR" || die "Failed to change to temp directory"
    
    # Get latest version
    local version
    version=$(get_latest_version)
    log_info "Latest version: v${version}"
    
    # Download
    local download_url="https://github.com/jesseduffield/lazygit/releases/download/v${version}/lazygit_${version}_Linux_x86_64.tar.gz"
    log_info "Downloading lazygit from GitHub..."
    curl -Lo lazygit.tar.gz "$download_url" || die "Failed to download lazygit"
    
    # Extract
    log_info "Extracting lazygit..."
    tar xf lazygit.tar.gz lazygit || die "Failed to extract lazygit"
    
    # Install to /usr/local/bin
    log_info "Installing lazygit to /usr/local/bin..."
    install lazygit -D -t /usr/local/bin/ || die "Failed to install lazygit"
    
    # Clean up
    cd - >/dev/null || true
    rm -rf "$TEMP_DIR"
    
    log_info "lazygit installed successfully"
}

# Verify lazygit installation
verify_lazygit() {
    log_info "Verifying lazygit installation..."
    
    if ! command -v lazygit &>/dev/null; then
        die "lazygit not found in PATH"
    fi
    
    if [[ ! -x "$LAZYGIT_BIN" ]]; then
        die "lazygit not executable at $LAZYGIT_BIN"
    fi
    
    local version
    version=$(lazygit --version 2>/dev/null | head -1 || echo "unknown")
    log_info "lazygit installed: $version"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_dependencies
    install_lazygit
    verify_lazygit
    log_info "lazygit installation complete"
}

main "$@"
