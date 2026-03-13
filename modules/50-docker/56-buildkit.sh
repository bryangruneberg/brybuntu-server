#!/bin/bash
# Docker BuildKit Configuration Module
# Enables Docker BuildKit by default and verifies buildx plugin availability

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# BuildKit Configuration Functions
# ============================================================================

# Verify Docker is installed
check_docker_installed() {
    log_info "Checking Docker installation..."

    if ! command -v docker &>/dev/null; then
        die "Docker is not installed. Please run 50-docker-engine.sh first"
    fi

    log_info "Docker is installed"
}

# Verify buildx plugin is available
verify_buildx_available() {
    log_info "Checking buildx plugin availability..."

    if ! docker buildx version &>/dev/null; then
        die "Docker buildx plugin is not available"
    fi

    local buildx_version
    buildx_version=$(docker buildx version | head -1)
    log_info "buildx version: $buildx_version"
}

# Configure BuildKit via environment variable in profile.d
configure_buildkit_env() {
    log_info "Configuring BuildKit environment..."

    local profile_file="/etc/profile.d/docker-buildkit.sh"
    local expected_content='# Enable Docker BuildKit by default
export DOCKER_BUILDKIT=1'

    # Check if file exists with correct content
    if [[ -f "$profile_file" ]]; then
        if [[ "$(cat "$profile_file")" == "$expected_content" ]]; then
            log_info "BuildKit environment already configured correctly"
            return 0
        else
            log_warn "Existing profile.d file found with different content, updating..."
        fi
    fi

    # Create the profile.d script with atomic file creation
    echo 'export DOCKER_BUILDKIT=1' | install -m 644 /dev/stdin "$profile_file"
    log_info "Created $profile_file"

    # Verify file was created correctly
    if [[ ! -f "$profile_file" ]]; then
        die "Failed to create $profile_file"
    fi

    local perms
    perms=$(stat -c "%a" "$profile_file")
    if [[ "$perms" != "644" ]]; then
        chmod 644 "$profile_file" || die "Failed to set permissions on $profile_file"
    fi

    log_info "BuildKit environment configured successfully"
}

# Display configuration summary
show_buildkit_summary() {
    log_info "================================================"
    log_info "Docker BuildKit Configuration Complete"
    log_info "================================================"
    log_info "BuildKit is now enabled by default via"
    log_info "/etc/profile.d/docker-buildkit.sh"
    log_info ""
    log_info "Note: New shells will automatically use BuildKit."
    log_info "Current session can enable it with:"
    log_info "  export DOCKER_BUILDKIT=1"
    log_info "================================================"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    check_root
    check_docker_installed
    verify_buildx_available
    configure_buildkit_env
    show_buildkit_summary

    log_info "BuildKit configuration complete"
}

main "$@"
