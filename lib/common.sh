#!/bin/bash
# Brybuntu Server Setup - Common Library
# Shared utilities for logging, error handling, and system validation

# Source guard: prevent double-sourcing
if [[ -n "${BRYBUNTU_COMMON:-}" ]]; then
    return 0
fi
readonly BRYBUNTU_COMMON=1

# ============================================================================
# Color Definitions
# ============================================================================

# Check if stdout is a TTY for color support
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly NC='\033[0m' # No Color
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly NC=''
fi

# ============================================================================
# Logging Functions
# ============================================================================

# Log an info message to stdout
# Usage: log_info "message"
log_info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$1"
}

# Log a warning message to stderr
# Usage: log_warn "message"
log_warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$1" >&2
}

# Log an error message to stderr
# Usage: log_error "message"
log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$1" >&2
}

# ============================================================================
# Error Handling Functions
# ============================================================================

# Log an error and exit with code 1
# Usage: die "error message"
die() {
    log_error "$1"
    exit 1
}

# ============================================================================
# System Validation Functions
# ============================================================================

# Check if running as root (EUID == 0)
# Dies with error if not running as root
# Usage: check_root
check_root() {
    if [[ "$EUID" -ne 0 ]]; then
        die "Must run as root"
    fi
}

# Validate that the system is Ubuntu
# Warns if version is not 24.04
# Usage: validate_ubuntu
validate_ubuntu() {
    if [[ ! -f /etc/os-release ]]; then
        die '/etc/os-release not found'
    fi

    local ID VERSION_ID
    # shellcheck source=/dev/null
    source /etc/os-release

    if [[ "$ID" != "ubuntu" ]]; then
        log_warn "Not running on Ubuntu (detected: $ID)"
        return 1
    fi

    if [[ "$VERSION_ID" != "24.04" ]]; then
        log_warn "Ubuntu version $VERSION_ID detected. Tested on 24.04."
    fi
}

# ============================================================================
# Best Practices (for use with 'set' in calling scripts)
# ============================================================================
#
# Recommended strict mode for calling scripts:
#   set -euo pipefail
#
#   -e: Exit immediately if a command exits with non-zero status
#   -u: Treat unset variables as an error
#   -o pipefail: Pipeline returns exit status of last command to exit non-zero
#
# When using strict mode, use explicit error checking:
#   command || die "message"
#
# ============================================================================
