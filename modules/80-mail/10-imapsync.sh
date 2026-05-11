#!/bin/bash
# imapsync Installation Module
# Installs imapsync for IMAP-to-IMAP mail synchronisation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "${SCRIPT_DIR}/../../lib/common.sh"

# ============================================================================
# Installation
# ============================================================================
install_imapsync() {
    if command -v imapsync &>/dev/null; then
        log_info "imapsync already installed, skipping"
        return 0
    fi

    log_info "Installing imapsync..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get install -y imapsync || die "Failed to install imapsync"
    log_info "imapsync installed successfully"
}

# ============================================================================
# Verification
# ============================================================================
verify_imapsync() {
    command -v imapsync &>/dev/null || die "imapsync not found after installation"
    log_info "imapsync version: $(imapsync --version 2>&1 | head -1)"
}

# ============================================================================
# Main Execution
# ============================================================================
main() {
    install_imapsync
    verify_imapsync
    log_info "imapsync setup complete"
}

main "$@"
