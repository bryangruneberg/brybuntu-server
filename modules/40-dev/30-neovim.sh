#!/bin/bash
# Neovim Installation Module
# Installs Neovim v0.11.6 via AppImage extraction

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Configuration
# ============================================================================

readonly NEOVIM_VERSION="0.11.6"
readonly NEOVIM_URL="https://github.com/neovim/neovim/releases/download/v${NEOVIM_VERSION}/nvim-linux-x86_64.appimage"
readonly NEOVIM_APPIMAGE="/opt/nvim-${NEOVIM_VERSION}.appimage"
readonly NEOVIM_EXTRACT_DIR="/opt/nvim-${NEOVIM_VERSION}"
readonly NEOVIM_BIN="/usr/local/bin/nvim"

# ============================================================================
# Neovim Installation Functions
# ============================================================================

# Download Neovim AppImage
download_neovim() {
    log_info "Downloading Neovim v${NEOVIM_VERSION}..."
    
    if [[ -f "$NEOVIM_APPIMAGE" ]]; then
        log_info "AppImage already downloaded, skipping download"
        return 0
    fi
    
    curl -fsSL -o "$NEOVIM_APPIMAGE" "$NEOVIM_URL" || die "Failed to download Neovim AppImage"
    chmod +x "$NEOVIM_APPIMAGE" || die "Failed to make AppImage executable"
    log_info "Download complete"
}

# Extract Neovim AppImage
extract_neovim() {
    log_info "Extracting Neovim AppImage..."
    
    if [[ -d "$NEOVIM_EXTRACT_DIR" ]]; then
        log_info "Neovim already extracted, skipping extraction"
        return 0
    fi
    
    # Create extraction directory
    mkdir -p "$NEOVIM_EXTRACT_DIR" || die "Failed to create extraction directory"
    
    # Extract using --appimage-extract
    cd "$NEOVIM_EXTRACT_DIR" || die "Failed to change to extraction directory"
    "$NEOVIM_APPIMAGE" --appimage-extract >/dev/null 2>&1 || die "Failed to extract AppImage"
    
    log_info "Extraction complete"
}

# Create symlink for nvim binary
create_symlink() {
    log_info "Creating nvim symlink..."
    
    # Remove existing symlink if present
    if [[ -L "$NEOVIM_BIN" ]]; then
        rm "$NEOVIM_BIN" || die "Failed to remove existing nvim symlink"
    fi
    
    # Create new symlink
    ln -s "${NEOVIM_EXTRACT_DIR}/squashfs-root/AppRun" "$NEOVIM_BIN" || die "Failed to create nvim symlink"
    
    log_info "Symlink created at $NEOVIM_BIN"
}

# Verify Neovim installation
verify_neovim() {
    log_info "Verifying Neovim installation..."
    
    if ! command -v nvim &>/dev/null; then
        die "nvim not found in PATH"
    fi
    
    local installed_version
    installed_version=$(nvim --version | head -1 | grep -oP 'v\K[0-9.]+' || echo "unknown")
    log_info "Neovim v${installed_version} installed successfully"
}

# Install Neovim
install_neovim() {
    log_info "Starting Neovim installation..."
    
    # Check if already installed
    if command -v nvim &>/dev/null; then
        local current_version
        current_version=$(nvim --version | head -1 | grep -oP 'v\K[0-9.]+' || echo "unknown")
        log_info "Neovim v${current_version} already installed"
        
        # Check if it's the correct version
        if [[ "$current_version" == "$NEOVIM_VERSION" ]]; then
            log_info "Correct version already installed, skipping"
            return 0
        else
            log_warn "Different version installed (v${current_version}), reinstalling v${NEOVIM_VERSION}..."
        fi
    fi
    
    # Install dependencies
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || true
    apt-get install -y -qq curl || die "Failed to install curl"
    
    # Download, extract, and symlink
    download_neovim
    extract_neovim
    create_symlink
    verify_neovim
    
    log_info "Neovim installation complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_neovim
}

main "$@"
