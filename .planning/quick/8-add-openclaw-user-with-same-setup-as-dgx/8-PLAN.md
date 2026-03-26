---
phase: quick-8
plan: 01
type: execute
wave: 1
depends_on: []
files_modified:
  - modules/20-users/16-openclaw.sh
  - modules/30-sudo/16-openclaw-sudo.sh
  - modules/40-dev/46-openclaw-lazyvim.sh
  - modules/50-docker/52-docker-config.sh
  - modules/60-ssh-keys/10-generate-ssh-keys.sh
  - modules/70-utilities/10-display-ssh-keys.sh
autonomous: true
requirements:
  - QUICK-08-01
  - QUICK-08-02
  - QUICK-08-03
must_haves:
  truths:
    - "openclaw user exists on the system"
    - "openclaw user can SSH with the provided public key"
    - "openclaw user has passwordless sudo access"
    - "openclaw user has LazyVim configured"
    - "openclaw user is in the docker group"
    - "openclaw user has SSH key generated"
    - "openclaw SSH public key is displayed in the utility module"
  artifacts:
    - path: "modules/20-users/16-openclaw.sh"
      provides: "openclaw user creation with SSH key"
      exports: ["main"]
      executable: true
    - path: "modules/30-sudo/16-openclaw-sudo.sh"
      provides: "openclaw passwordless sudo configuration"
      exports: ["main"]
      executable: true
    - path: "modules/40-dev/46-openclaw-lazyvim.sh"
      provides: "openclaw LazyVim installation"
      exports: ["main"]
      executable: true
  key_links:
    - from: "modules/20-users/16-openclaw.sh"
      to: "lib/user.sh"
      via: "user_create_with_ssh function"
      pattern: "source.*lib/user.sh"
    - from: "modules/30-sudo/16-openclaw-sudo.sh"
      to: "lib/sudo.sh"
      via: "sudoers_create_nopasswd function"
      pattern: "source.*lib/sudo.sh"
    - from: "modules/40-dev/46-openclaw-lazyvim.sh"
      to: "lib/dev.sh"
      via: "install_lazyvim_for_user function"
      pattern: "source.*lib/dev.sh"
    - from: "modules/50-docker/52-docker-config.sh"
      to: "USERS array"
      via: "Array modification"
      pattern: "USERS=\(bryan amazeeio dgxc openclaw\)"
---

<objective>
Add "openclaw" user to the Brybuntu server setup with identical configuration to dgxc, bryan, and amazeeio users.

Purpose: Enable the openclaw user to have SSH access, passwordless sudo, LazyVim development environment, Docker access, and SSH key generation just like existing admin users.

Output: Three new module scripts (user creation, sudo config, LazyVim setup) and updates to three existing modules (Docker config, SSH key generation, SSH key display).
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/execute-plan.md
@./.opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@modules/20-users/15-dgxc.sh
@modules/30-sudo/15-dgxc-sudo.sh
@modules/40-dev/45-dgxc-lazyvim.sh
@modules/50-docker/52-docker-config.sh
@modules/60-ssh-keys/10-generate-ssh-keys.sh
@modules/70-utilities/10-display-ssh-keys.sh

## Pattern Analysis from Existing Files

### User Creation Pattern (modules/20-users/15-dgxc.sh)
- Uses lib/user.sh library
- Defines SSH public keys (main + mobile) as readonly variables
- Calls user_create_with_ssh function with username and key
- Can add multiple SSH keys for same user

### Sudo Configuration Pattern (modules/30-sudo/15-dgxc-sudo.sh)
- Uses lib/sudo.sh library
- Calls sudoers_create_nopasswd with username
- Function validates syntax with visudo before installation

### LazyVim Installation Pattern (modules/40-dev/45-dgxc-lazyvim.sh)
- Uses lib/dev.sh library
- Calls install_lazyvim_for_user with username
- Checks for git and Neovim prerequisites

### Docker Configuration Pattern (modules/50-docker/52-docker-config.sh)
- USERS array: local USERS=(bryan amazeeio dgxc)
- add_users_to_docker function iterates array and adds users to docker group
- Need to append "openclaw" to the array

### SSH Key Generation Pattern (modules/60-ssh-keys/10-generate-ssh-keys.sh)
- users array: local users=("root" "bryan" "amazeeio" "dgxc")
- verify_ssh_keys function also uses this array
- Need to append "openclaw" to the array

### SSH Key Display Pattern (modules/70-utilities/10-display-ssh-keys.sh)
- users array: local users=("root" "bryan" "amazeeio" "dgxc")
- display_ssh_keys function iterates and shows public keys
- Need to append "openclaw" to the array
</context>

<tasks>

<task type="auto">
  <name>Create openclaw user modules (creation, sudo, LazyVim)</name>
  <files>modules/20-users/16-openclaw.sh, modules/30-sudo/16-openclaw-sudo.sh, modules/40-dev/46-openclaw-lazyvim.sh</files>
  <action>
Create three new module scripts following the dgxc pattern:

1. modules/20-users/16-openclaw.sh:
   - Copy structure from 15-dgxc.sh
   - Replace "dgxc" with "openclaw"
   - Use the SAME SSH public key as bryan@bryarchy (same pattern as dgxc and amazeeio):
     "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKt9pdXZ/aI31oyRrCc7ER8pfTOcS3r04xVnEOmEjhss bryan@bryarchy"
   - No mobile key needed unless specified by user (dgxc has one, but bryan/amazeeio do not)
   - Make executable: chmod +x

2. modules/30-sudo/16-openclaw-sudo.sh:
   - Copy structure from 15-dgxc-sudo.sh
   - Replace "dgxc" with "openclaw"
   - Call sudoers_create_nopasswd "openclaw"
   - Make executable: chmod +x

3. modules/40-dev/46-openclaw-lazyvim.sh:
   - Copy structure from 45-dgxc-lazyvim.sh
   - Replace "dgxc" with "openclaw"
   - Call install_lazyvim_for_user "openclaw"
   - Make executable: chmod +x

All scripts must:
- Use set -euo pipefail
- Source appropriate libraries from ../../lib/
- Include proper #!/bin/bash shebang
- Include module comments explaining purpose
  </action>
  <verify>
    <automated>
      # Verify files exist
      ls -la modules/20-users/16-openclaw.sh modules/30-sudo/16-openclaw-sudo.sh modules/40-dev/46-openclaw-lazyvim.sh
      # Check they are executable
      test -x modules/20-users/16-openclaw.sh && test -x modules/30-sudo/16-openclaw-sudo.sh && test -x modules/40-dev/46-openclaw-lazyvim.sh && echo "All executable"
      # Validate bash syntax
      bash -n modules/20-users/16-openclaw.sh && bash -n modules/30-sudo/16-openclaw-sudo.sh && bash -n modules/40-dev/46-openclaw-lazyvim.sh && echo "Syntax OK"
      # Verify openclaw string appears in files
      grep -l "openclaw" modules/20-users/16-openclaw.sh modules/30-sudo/16-openclaw-sudo.sh modules/40-dev/46-openclaw-lazyvim.sh
    </automated>
  </verify>
  <done>
    - Three new module scripts exist and are executable
    - Each contains "openclaw" username references
    - Each validates with "bash -n" (syntax OK)
    - SSH key uses bryan@bryarchy public key (same as dgxc/amazeeio pattern)
  </done>
</task>

<task type="auto">
  <name>Update existing modules to include openclaw user</name>
  <files>modules/50-docker/52-docker-config.sh, modules/60-ssh-keys/10-generate-ssh-keys.sh, modules/70-utilities/10-display-ssh-keys.sh</files>
  <action>
Update three existing modules to add "openclaw" to their user arrays:

1. modules/50-docker/52-docker-config.sh:
   - Change line 32: local USERS=(bryan amazeeio dgxc)
   - To: local USERS=(bryan amazeeio dgxc openclaw)

2. modules/60-ssh-keys/10-generate-ssh-keys.sh:
   - Change line 77: local users=("root" "bryan" "amazeeio" "dgxc")
   - To: local users=("root" "bryan" "amazeeio" "dgxc" "openclaw")
   - Also update line 136 comment to mention openclaw

3. modules/70-utilities/10-display-ssh-keys.sh:
   - Change line 15: local users=("root" "bryan" "amazeeio" "dgxc")
   - To: local users=("root" "bryan" "amazeeio" "dgxc" "openclaw")
   - Also update line 3 comment to mention openclaw

Use replaceAll to update all occurrences consistently.
  </action>
  <verify>
    <automated>
      # Verify arrays include openclaw
      grep "USERS=(bryan amazeeio dgxc openclaw)" modules/50-docker/52-docker-config.sh && echo "Docker config OK"
      grep 'users=("root" "bryan" "amazeeio" "dgxc" "openclaw")' modules/60-ssh-keys/10-generate-ssh-keys.sh && echo "SSH keys OK"
      grep 'users=("root" "bryan" "amazeeio" "dgxc" "openclaw")' modules/70-utilities/10-display-ssh-keys.sh && echo "Utilities OK"
      # Validate bash syntax on modified files
      bash -n modules/50-docker/52-docker-config.sh && bash -n modules/60-ssh-keys/10-generate-ssh-keys.sh && bash -n modules/70-utilities/10-display-ssh-keys.sh && echo "All syntax OK"
    </automated>
  </verify>
  <done>
    - Docker config module includes openclaw in USERS array
    - SSH key generation includes openclaw in users array
    - SSH key display includes openclaw in users array
    - All modified files validate with "bash -n"
    - Comments updated to mention openclaw where appropriate
  </done>
</task>

</tasks>

<verification>
After completing both tasks:
1. All six files have been created or modified
2. All new files are executable (chmod +x)
3. All files pass "bash -n" syntax validation
4. The openclaw user is consistently referenced across all modules
5. SSH key pattern matches existing users (bryan@bryarchy key)
</verification>

<success_criteria>
- Three new module scripts created for openclaw (user creation, sudo, LazyVim)
- Three existing modules updated to include openclaw in user arrays
- All files executable and syntactically valid
- Pattern consistent with dgxc, bryan, and amazeeio users
</success_criteria>

<output>
After completion, create `.planning/quick/8-add-openclaw-user-with-same-setup-as-dgx/8-SUMMARY.md`

Summary should include:
- Files created: modules/20-users/16-openclaw.sh, modules/30-sudo/16-openclaw-sudo.sh, modules/40-dev/46-openclaw-lazyvim.sh
- Files modified: modules/50-docker/52-docker-config.sh, modules/60-ssh-keys/10-generate-ssh-keys.sh, modules/70-utilities/10-display-ssh-keys.sh
- SSH key used: bryan@bryarchy Ed25519 key (same as other admin users)
- All scripts executable and syntax validated
</output>
