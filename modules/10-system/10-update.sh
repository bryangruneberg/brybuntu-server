#!/bin/bash
# System Update Module
# Runs apt update to refresh package lists

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# System Update Functions
# ============================================================================

# Update package lists from repositories
# Dies if apt update fails
update_system() {
    log_info "Updating package lists..."
    
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || die "apt update failed"
    
    log_info "System update complete"
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    update_system
}

main "$@"
