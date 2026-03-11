#!/bin/bash
# Brybuntu Server Setup - Main Orchestrator
# Discovers and executes numbered modules in order

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source common library
# shellcheck source=lib/common.sh
source "${SCRIPT_DIR}/lib/common.sh"

# ============================================================================
# Module Discovery
# ============================================================================

# Discover modules matching [0-9][0-9]-*.sh pattern
# Outputs sorted list of module paths
discover_modules() {
    local modules_dir="$1"

    if [[ ! -d "$modules_dir" ]]; then
        return 0
    fi

    # Find numbered scripts and sort by version number
    find "$modules_dir" -maxdepth 2 -name "[0-9][0-9]-*.sh" -type f | sort -V
}

# ============================================================================
# Module Execution
# ============================================================================

# Execute a single module
# Dies if module fails
execute_module() {
    local script="$1"
    local module_name
    module_name=$(basename "$script")

    log_info "Executing module: $module_name"

    # Execute with bash, fail-fast on error
    if ! bash "$script"; then
        die "Module failed: $module_name"
    fi

    log_info "Module completed: $module_name"
}

# ============================================================================
# Main
# ============================================================================

main() {
    log_info "Starting Brybuntu Server Setup"

    # Validate environment
    check_root
    validate_ubuntu

    # Discover modules
    local modules_dir="${SCRIPT_DIR}/modules"
    log_info "Discovering modules in: $modules_dir"

    local modules
    modules=$(discover_modules "$modules_dir")

    if [[ -z "$modules" ]]; then
        log_warn "No modules found in $modules_dir"
        log_info "Setup complete (no modules to execute)"
        exit 0
    fi

    # Count modules
    local count
    count=$(echo "$modules" | wc -l)
    log_info "Found $count module(s) to execute"

    # Execute each module
    local executed=0
    while IFS= read -r script; do
        [[ -n "$script" ]] || continue
        execute_module "$script"
        ((executed++))
    done < <(discover_modules "$modules_dir")

    log_info "========================================"
    log_info "Setup complete! Executed $executed module(s)"
    log_info "========================================"
}

# Execute main
main "$@"
