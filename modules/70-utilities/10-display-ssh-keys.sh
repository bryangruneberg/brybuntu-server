#!/bin/bash
# Display SSH Public Keys Module
# Displays Ed25519 public keys for root, bryan, and amazeeio

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# SSH Key Display Functions
# ============================================================================

display_ssh_keys() {
    local users=("root" "bryan" "amazeeio")
    local first_key=true
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo "  SSH PUBLIC KEYS FOR COPY/PASTE"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
    
    for user in "${users[@]}"; do
        local ssh_dir
        local pub_key_path
        
        # Determine SSH directory based on user
        if [[ "$user" == "root" ]]; then
            ssh_dir="/root/.ssh"
        else
            ssh_dir="/home/$user/.ssh"
        fi
        pub_key_path="$ssh_dir/id_ed25519.pub"
        
        # Display user header
        echo ""
        echo "─── $user ───"
        echo ""
        
        # Check if public key exists
        if [[ -f "$pub_key_path" ]]; then
            # Display the key
            cat "$pub_key_path"
            first_key=false
        else
            log_warn "No SSH key found for $user at $pub_key_path"
        fi
    done
    
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    echo ""
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    display_ssh_keys
}

main "$@"
