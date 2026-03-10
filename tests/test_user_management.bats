#!/usr/bin/env bats
# User Management Test Suite
# Integration tests for user creation and SSH key setup
#
# NOTE: These tests verify actual system state and require the users to exist.
# Run after executing the user creation modules.

# ============================================================================
# Bryan User Tests
# ============================================================================

@test "bryan user exists" {
    run id bryan
    [[ $status -eq 0 ]]
}

@test "bryan home directory exists" {
    [[ -d /home/bryan ]]
}

@test "bryan .ssh directory has 700 permissions" {
    run stat -c %a /home/bryan/.ssh
    [[ $output == "700" ]]
}

@test "bryan authorized_keys has 600 permissions" {
    run stat -c %a /home/bryan/.ssh/authorized_keys
    [[ $output == "600" ]]
}

@test "bryan authorized_keys contains Ed25519 key" {
    run grep -q "ssh-ed25519" /home/bryan/.ssh/authorized_keys
    [[ $status -eq 0 ]]
}

# ============================================================================
# amazeeio User Tests
# ============================================================================

@test "amazeeio user exists" {
    run id amazeeio
    [[ $status -eq 0 ]]
}

@test "amazeeio home directory exists" {
    [[ -d /home/amazeeio ]]
}

@test "amazeeio .ssh directory has 700 permissions" {
    run stat -c %a /home/amazeeio/.ssh
    [[ $output == "700" ]]
}

@test "amazeeio authorized_keys has 600 permissions" {
    run stat -c %a /home/amazeeio/.ssh/authorized_keys
    [[ $output == "600" ]]
}

@test "amazeeio authorized_keys contains Ed25519 key" {
    run grep -q "ssh-ed25519" /home/amazeeio/.ssh/authorized_keys
    [[ $status -eq 0 ]]
}
