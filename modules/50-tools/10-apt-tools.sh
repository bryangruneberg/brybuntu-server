#!/bin/bash
# Neovim Dependencies - APT Tools Installation Module
# Installs: ripgrep, build-essential, luarocks, imagemagick, fd-find

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# APT Packages Installation Functions
# ============================================================================

# Check if a package is already installed
is_package_installed() {
    local package="$1"
    dpkg -l "$package" 2>/dev/null | grep -q "^ii"
}

# Install a single package if not already installed
install_package() {
    local package="$1"
    
    if is_package_installed "$package"; then
        log_info "Package '$package' already installed, skipping"
        return 0
    fi
    
    log_info "Installing package: $package"
    apt-get install -y -qq "$package" || die "Failed to install package: $package"
    log_info "Package '$package' installed successfully"
}

# Install all apt packages
install_apt_packages() {
    log_info "Starting apt packages installation..."
    
    # Update package list
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || die "Failed to update package list"
    
    # Install each package
    install_package "ripgrep"
    install_package "build-essential"
    install_package "luarocks"
    install_package "imagemagick"
    install_package "fd-find"
    install_package "kitty"
    
    log_info "All apt packages installed successfully"
}

# Create symlink for fd command
# fd-find installs as 'fdfind', but tools expect 'fd'
create_fd_symlink() {
    log_info "Creating fd symlink..."
    
    local fdfind_path
    fdfind_path=$(which fdfind 2>/dev/null || echo "")
    
    if [[ -z "$fdfind_path" ]]; then
        die "fdfind not found in PATH after installation"
    fi
    
    # Check if symlink already exists and points to correct location
    if [[ -L "/usr/local/bin/fd" ]]; then
        local current_target
        current_target=$(readlink -f "/usr/local/bin/fd" 2>/dev/null || echo "")
        if [[ "$current_target" == "$fdfind_path" ]]; then
            log_info "fd symlink already exists and is correct, skipping"
            return 0
        else
            log_warn "fd symlink exists but points to different target, recreating..."
            rm -f "/usr/local/bin/fd"
        fi
    elif [[ -e "/usr/local/bin/fd" ]]; then
        log_warn "/usr/local/bin/fd exists but is not a symlink, backing up..."
        mv "/usr/local/bin/fd" "/usr/local/bin/fd.backup.$(date +%s)"
    fi
    
    ln -s "$fdfind_path" /usr/local/bin/fd || die "Failed to create fd symlink"
    log_info "fd symlink created: /usr/local/bin/fd -> $fdfind_path"
}

# Verify all installations
verify_installations() {
    log_info "Verifying installations..."
    
    # Verify packages
    local packages=("ripgrep" "build-essential" "luarocks" "imagemagick" "fd-find")
    for package in "${packages[@]}"; do
        if ! is_package_installed "$package"; then
            die "Package '$package' not found after installation"
        fi
    done
    
    # Verify fd symlink
    if ! command -v fd &>/dev/null; then
        die "fd command not found after symlink creation"
    fi
    
    # Show versions
    log_info "ripgrep version: $(rg --version | head -1)"
    log_info "luarocks version: $(luarocks --version 2>/dev/null | head -1 || echo 'N/A')"
    log_info "fd version: $(fd --version)"
    
    log_info "All verifications passed"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_apt_packages
    create_fd_symlink
    verify_installations
    log_info "APT tools installation complete"
}

main "$@"
