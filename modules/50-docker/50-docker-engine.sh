#!/bin/bash
# Docker Engine Installation Module
# Installs Docker Engine and CLI from official Docker apt repository

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Docker Engine Installation Functions
# ============================================================================

# Install Docker Engine from official Docker repository
install_docker_engine() {
    log_info "Starting Docker Engine installation..."

    # Check if Docker is already installed and get version
    if command -v docker &>/dev/null; then
        local current_version
        current_version=$(docker --version 2>/dev/null | head -1 || echo "installed")
        log_info "Docker $current_version already installed, skipping"
        return 0
    fi

    # Install required dependencies
    log_info "Installing prerequisites..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || die "Failed to update package list"
    apt-get install -y -qq ca-certificates curl gnupg || die "Failed to install prerequisites"

    # Add Docker's official GPG key
    log_info "Adding Docker GPG key..."
    install -m 0755 -d /etc/apt/keyrings || die "Failed to create keyrings directory"
    curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg || die "Failed to download Docker GPG key"
    chmod a+r /etc/apt/keyrings/docker.gpg || die "Failed to set permissions on GPG key"

    # Add Docker repository to apt sources
    log_info "Adding Docker apt repository..."
    local arch
    arch=$(dpkg --print-architecture)
    echo "deb [arch="${arch}" signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" > /etc/apt/sources.list.d/docker.list || die "Failed to add Docker repository"

    # Update apt cache with new repository
    apt-get update -qq || die "Failed to update package list with Docker repository"

    # Install Docker Engine and CLI
    log_info "Installing Docker Engine and CLI..."
    apt-get install -y -qq docker-ce docker-ce-cli containerd.io || die "Failed to install Docker packages"

    # Verify installation
    local docker_version
    docker_version=$(docker --version)
    log_info "Docker installed successfully: $docker_version"

    # Verify Docker daemon status
    if systemctl is-active --quiet docker 2>/dev/null; then
        log_info "Docker daemon is running"
    else
        log_warn "Docker daemon may not be running (expected on build systems)"
    fi

    log_info "Docker Engine installation complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_docker_engine
}

main "$@"
