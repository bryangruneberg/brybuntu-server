#!/bin/bash
# Brybuntu Server Setup - openclaw Sudo Configuration Module
# Configures passwordless sudo access for the openclaw user

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

log_info "Configuring sudo access for openclaw..."

# Create passwordless sudo rule for openclaw user
# This function validates syntax with visudo before installation
# to prevent root lockout from syntax errors
sudoers_create_nopasswd "openclaw"

log_info "openclaw sudo configuration complete"
