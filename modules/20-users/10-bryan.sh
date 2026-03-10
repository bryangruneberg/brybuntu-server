#!/bin/bash
# Bryan User Creation Module
# Creates the bryan admin user with SSH key access

set -euo pipefail

# Calculate script directory for sourcing libraries
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
# shellcheck source=../../lib/common.sh
source "${SCRIPT_DIR}/../../lib/common.sh"

# Source user management library
# shellcheck source=../../lib/user.sh
source "${SCRIPT_DIR}/../../lib/user.sh"

# ============================================================================
# SSH Key
# ============================================================================

# Bryan's Ed25519 SSH public key
readonly BRYAN_SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKt9pdXZ/aI31oyRrCc7ER8pfTOcS3r04xVnEOmEjhss bryan@bryarchy"

# ============================================================================
# Main Execution
# ============================================================================

main() {
    check_root

    log_info "Setting up bryan user..."

    # Create user with SSH key access
    user_create_with_ssh "bryan" "$BRYAN_SSH_KEY"

    log_info "bryan user setup complete"
}

main "$@"
