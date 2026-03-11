#!/bin/bash
# TeXLive Installation Module
# Installs: texlive-latex-base, texlive-latex-recommended, texlive-latex-extra

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# TeXLive Installation Functions
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
    DEBIAN_FRONTEND=noninteractive apt-get install -y -qq "$package" || die "Failed to install package: $package"
    log_info "Package '$package' installed successfully"
}

# Install all texlive packages
install_texlive_packages() {
    log_info "Starting TeXLive packages installation..."

    # Update package list
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || die "Failed to update package list"

    # Install texlive packages
    install_package "texlive-latex-base"
    install_package "texlive-latex-recommended"
    install_package "texlive-latex-extra"

    log_info "All TeXLive packages installed successfully"
}

# Verify all installations
verify_installations() {
    log_info "Verifying TeXLive installations..."

    # Verify packages
    local packages=("texlive-latex-base" "texlive-latex-recommended" "texlive-latex-extra")
    for package in "${packages[@]}"; do
        if ! is_package_installed "$package"; then
            die "Package '$package' not found after installation"
        fi
    done

    # Verify pdflatex is available
    if ! command -v pdflatex &>/dev/null; then
        die "pdflatex command not found after installation"
    fi

    # Show version
    log_info "pdflatex version: $(pdflatex --version | head -1)"

    log_info "All TeXLive verifications passed"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_texlive_packages
    verify_installations
    log_info "TeXLive installation complete"
}

main "$@"
