#!/bin/bash
# Docker Configuration Module
# Configures Docker group membership for admin users and enables auto-start

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# Docker Group and User Configuration Functions
# ============================================================================

# Ensure docker group exists
ensure_docker_group() {
    log_info "Ensuring docker group exists..."

    if getent group docker &>/dev/null; then
        log_info "Docker group already exists"
    else
        log_info "Creating docker group..."
        groupadd docker || die "Failed to create docker group"
        log_info "Docker group created successfully"
    fi
}

# Add admin users to docker group for non-root access
add_users_to_docker() {
    log_info "Configuring Docker group membership..."

    # Admin users who need Docker access
    local USERS=(bryan amazeeio dgxc)

    for user in "${USERS[@]}"; do
        # Check if user exists
        if ! id "$user" &>/dev/null; then
            log_warn "User '$user' does not exist, skipping"
            continue
        fi

        # Check if user is already in docker group
        if groups "$user" | grep -q docker; then
            log_info "User '$user' already in docker group, skipping"
            continue
        fi

        # Add user to docker group
        log_info "Adding user '$user' to docker group..."
        usermod -aG docker "$user" || die "Failed to add user '$user' to docker group"
        log_info "Added '$user' to docker group"
    done
}

# Configure Docker daemon to start automatically
configure_docker_daemon() {
    log_info "Configuring Docker daemon auto-start..."

    # Check if Docker is installed
    if ! command -v docker &>/dev/null; then
        die "Docker is not installed. Please run 50-docker-engine.sh first"
    fi

    # Enable Docker to start on boot and start it now
    if systemctl is-enabled --quiet docker 2>/dev/null; then
        log_info "Docker daemon already enabled for auto-start"
    else
        log_info "Enabling Docker daemon auto-start..."
        systemctl enable --now docker || die "Failed to enable Docker daemon"
        log_info "Docker daemon enabled for auto-start"
    fi

    # Verify daemon is running
    if systemctl is-active --quiet docker 2>/dev/null; then
        log_info "Docker daemon is active"
    else
        log_warn "Docker daemon is not running (may require system restart)"
    fi
}

# Display logout warning for group membership
show_logout_warning() {
    log_warn "================================================"
    log_warn "IMPORTANT: Docker group membership change"
    log_warn "================================================"
    log_warn "Users must logout and login again for Docker"
    log_warn "group membership to take effect."
    log_warn ""
    log_warn "After re-login, test with: docker ps"
    log_warn "================================================"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    check_root
    ensure_docker_group
    add_users_to_docker
    configure_docker_daemon
    show_logout_warning

    log_info "Docker configuration complete"
}

main "$@"
