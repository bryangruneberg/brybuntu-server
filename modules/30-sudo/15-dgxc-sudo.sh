#!/bin/bash
# Brybuntu Server Setup - dgxc Sudo Configuration Module
# Configures passwordless sudo access for the dgxc user

set -euo pipefail

# Calculate script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
# shellcheck source=../../lib/common.sh
source "${SCRIPT_DIR}/../../lib/common.sh"

# Source sudo library
# shellcheck source=../../lib/sudo.sh
source "${SCRIPT_DIR}/../../lib/sudo.sh"

# ============================================================================
# Main
# ============================================================================

check_root

log_info "Configuring sudo access for dgxc..."

# Create passwordless sudo rule for dgxc user
# This function validates syntax with visudo before installation
# to prevent root lockout from syntax errors
sudoers_create_nopasswd "dgxc"

log_info "dgxc sudo configuration complete"
