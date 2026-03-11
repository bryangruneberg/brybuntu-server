#!/bin/bash
# Docker Compose Plugin Installation Module
# Installs Docker Compose v2 as Docker CLI plugin

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Docker Compose Installation Functions
# ============================================================================

# Install Docker Compose v2 plugin
install_docker_compose() {
    log_info "Starting Docker Compose plugin installation..."

    # Check if Docker Compose is already installed
    if docker compose version &>/dev/null 2>&1; then
        local current_version
        current_version=$(docker compose version 2>/dev/null | head -1 || echo "installed")
        log_info "Docker Compose $current_version already installed, skipping"
        return 0
    fi

    # Check if docker-compose-plugin is already installed via dpkg
    if dpkg -l docker-compose-plugin 2>/dev/null | grep -q "^ii"; then
        log_info "Docker Compose plugin already installed via apt, skipping"
        return 0
    fi

    # Install Docker Compose plugin
    log_info "Installing Docker Compose plugin..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || die "Failed to update package list"
    apt-get install -y -qq docker-compose-plugin || die "Failed to install Docker Compose plugin"

    # Verify installation
    local compose_version
    compose_version=$(docker compose version)
    log_info "Docker Compose installed successfully: $compose_version"

    log_info "Docker Compose plugin installation complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    install_docker_compose
}

main "$@"
