#!/bin/bash
# SSH Key Generation Module
# Generates Ed25519 SSH keys for root, bryan, and amazeeio users

set -euo pipefail

# Source common library
source "$(dirname "$0")/../../lib/common.sh"

# ============================================================================
# SSH Key Generation Functions
# ============================================================================

# Get home directory for a user
# Special case: root's home is /root, not /home/root
get_user_home() {
    local username="$1"

    if [[ "$username" == "root" ]]; then
        echo "/root"
    else
        echo "/home/$username"
    fi
}

# Generate SSH key for a user if it doesn't exist
generate_ssh_key_for_user() {
    local username="$1"

    log_info "Processing SSH key for user: $username"

    # Get home directory
    local home_dir
    home_dir=$(get_user_home "$username")

    local ssh_dir="$home_dir/.ssh"
    local private_key="$ssh_dir/id_ed25519"
    local public_key="$ssh_dir/id_ed25519.pub"

    # Check if user exists
    if ! id "$username" &>/dev/null; then
        log_warn "User $username does not exist, skipping"
        return 0
    fi

    # Check if key already exists (idempotency)
    if [[ -f "$private_key" ]]; then
        log_info "SSH key already exists for $username at $private_key, skipping"
        return 0
    fi

    # Ensure .ssh directory exists with correct permissions
    if [[ ! -d "$ssh_dir" ]]; then
        log_info "Creating .ssh directory for $username"
        mkdir -p "$ssh_dir" || die "Failed to create .ssh directory for $username"
    fi

    # Generate SSH key as the target user using su
    log_info "Generating Ed25519 SSH key for $username"
    su - "$username" -c "ssh-keygen -t ed25519 -N '' -f ~/.ssh/id_ed25519" || die "Failed to generate SSH key for $username"

    # Set correct permissions (ssh-keygen usually does this, but be explicit)
    chmod 700 "$ssh_dir" || die "Failed to set permissions on $ssh_dir"
    chmod 600 "$private_key" || die "Failed to set permissions on $private_key"
    chmod 644 "$public_key" || die "Failed to set permissions on $public_key"

    # Ensure correct ownership
    chown -R "$username:$username" "$ssh_dir" || die "Failed to set ownership on $ssh_dir"

    log_info "SSH key generated successfully for $username"
}

# Verify SSH keys for all users
verify_ssh_keys() {
    log_info "Verifying SSH keys..."

    local users=("root" "bryan" "amazeeio" "dgxc" "openclaw")
    local all_ok=true

    for username in "${users[@]}"; do
        local home_dir
        home_dir=$(get_user_home "$username")
        local private_key="$home_dir/.ssh/id_ed25519"
        local public_key="$home_dir/.ssh/id_ed25519.pub"

        # Check if user exists
        if ! id "$username" &>/dev/null; then
            log_warn "User $username does not exist"
            continue
        fi

        # Check private key
        if [[ ! -f "$private_key" ]]; then
            log_error "Private key not found for $username: $private_key"
            all_ok=false
            continue
        fi

        # Check public key
        if [[ ! -f "$public_key" ]]; then
            log_error "Public key not found for $username: $public_key"
            all_ok=false
            continue
        fi

        # Check permissions
        local priv_perms pub_perms
        priv_perms=$(stat -c %a "$private_key" 2>/dev/null || stat -f %Lp "$private_key" 2>/dev/null)
        pub_perms=$(stat -c %a "$public_key" 2>/dev/null || stat -f %Lp "$public_key" 2>/dev/null)

        if [[ "$priv_perms" != "600" ]]; then
            log_warn "Private key permissions for $username are $priv_perms (expected 600)"
        fi

        if [[ "$pub_perms" != "644" ]]; then
            log_warn "Public key permissions for $username are $pub_perms (expected 644)"
        fi

        log_info "SSH key verified for $username"
    done

    if [[ "$all_ok" == true ]]; then
        log_info "All SSH key verifications passed"
    else
        die "Some SSH key verifications failed"
    fi
}

# ============================================================================
# Main Execution
# ============================================================================

main() {
    check_root

    log_info "Starting SSH key generation for root, bryan, amazeeio, dgxc, and openclaw"

    # Generate keys for each user
    generate_ssh_key_for_user "root"
    generate_ssh_key_for_user "bryan"
    generate_ssh_key_for_user "amazeeio"
    generate_ssh_key_for_user "dgxc"
    generate_ssh_key_for_user "openclaw"

    # Verify all keys
    verify_ssh_keys

    log_info "SSH key generation complete"
}

main "$@"
