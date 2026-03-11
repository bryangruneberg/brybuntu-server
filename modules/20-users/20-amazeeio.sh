#!/bin/bash
# amazeeio User Creation Module
# Creates the amazeeio user with SSH key access

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

# amazeeio's Ed25519 SSH public key (same as bryan for initial setup)
readonly AMAZEEIO_SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKt9pdXZ/aI31oyRrCc7ER8pfTOcS3r04xVnEOmEjhss bryan@bryarchy"

# amazeeio's mobile Ed25519 SSH public key
readonly AMAZEEIO_MOBILE_SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINBh8/0u6pF/gTaSBkNYBXpGDPG1pODse1EX5hAkOw1l amazeeio-mobile"

# ============================================================================
# Main Execution
# ============================================================================

main() {
    check_root

    log_info "Setting up amazeeio user..."

    # Create user with SSH key access
    user_create_with_ssh "amazeeio" "$AMAZEEIO_SSH_KEY"

    # Add mobile SSH key
    user_create_with_ssh "amazeeio" "$AMAZEEIO_MOBILE_SSH_KEY"

    log_info "amazeeio user setup complete"
}

main "$@"
