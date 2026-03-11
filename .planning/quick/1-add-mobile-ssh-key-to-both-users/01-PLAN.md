---
phase: quick
type: execute
wave: 1
depends_on: []
files_modified:
  - modules/20-users/10-bryan.sh
  - modules/20-users/20-amazeeio.sh
autonomous: true
must_haves:
  truths:
    - Mobile SSH key added to bryan user authorized_keys
    - Mobile SSH key added to amazeeio user authorized_keys
    - Idempotency preserved (check-before-append pattern)
  artifacts:
    - path: modules/20-users/10-bryan.sh
      provides: Bryan user with mobile SSH key
      contains: BRYAN_MOBILE_SSH_KEY
    - path: modules/20-users/20-amazeeio.sh
      provides: amazeeio user with mobile SSH key
      contains: AMAZEEIO_MOBILE_SSH_KEY
  key_links:
    - from: mobile key constants
      to: user_create_with_ssh calls
      via: additional user_create_with_ssh invocation
---

## Objective
Add mobile SSH key to both bryan and amazeeio users for remote SSH access from mobile devices.

**Purpose:** Enable SSH login from mobile devices
**Output:** Both user modules updated with mobile SSH key support

<context>
@lib/user.sh
@modules/20-users/10-bryan.sh
@modules/20-users/20-amazeeio.sh
</context>

<tasks>

<task type="auto">
  <name>Task 1: Add mobile SSH key to bryan user</name>
  <files>modules/20-users/10-bryan.sh</files>
  <action>
Add mobile SSH key constant and second user_create_with_ssh call for bryan user:

1. Add after BRYAN_SSH_KEY:
   ```bash
   # Bryan's mobile Ed25519 SSH public key
   readonly BRYAN_MOBILE_SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKj0wr8mqZE9JuFvE9EE+1qsYZ/n8d0sKPAp4TWrCxY bryan-mobile"
   ```

2. In main(), after first user_create_with_ssh call, add:
   ```bash
   # Add mobile SSH key
   user_create_with_ssh "bryan" "$BRYAN_MOBILE_SSH_KEY"
   ```

The library's check-before-append idempotency handles duplicate keys gracefully.
  </action>
  <verify>
    <automated>grep -q "BRYAN_MOBILE_SSH_KEY" modules/20-users/10-bryan.sh && echo "PASS" || echo "FAIL"</automated>
  </verify>
  <done>Mobile SSH key constant defined and passed to user_create_with_ssh</done>
</task>

<task type="auto">
  <name>Task 2: Add mobile SSH key to amazeeio user</name>
  <files>modules/20-users/20-amazeeio.sh</files>
  <action>
Add mobile SSH key constant and second user_create_with_ssh call for amazeeio user:

1. Add after AMAZEEIO_SSH_KEY:
   ```bash
   # amazeeio's mobile Ed25519 SSH public key
   readonly AMAZEEIO_MOBILE_SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDKj0wr8mqZE9JuFvE9EE+1qsYZ/n8d0sKPAp4TWrCxY bryan-mobile"
   ```

2. In main(), after first user_create_with_ssh call, add:
   ```bash
   # Add mobile SSH key
   user_create_with_ssh "amazeeio" "$AMAZEEIO_MOBILE_SSH_KEY"
   ```

The library's check-before-append idempotency handles duplicate keys gracefully.
  </action>
  <verify>
    <automated>grep -q "AMAZEEIO_MOBILE_SSH_KEY" modules/20-users/20-amazeeio.sh && echo "PASS" || echo "FAIL"</automated>
  </verify>
  <done>Mobile SSH key constant defined and passed to user_create_with_ssh</done>
</task>

<task type="auto">
  <name>Task 3: Validate bash syntax</name>
  <files>modules/20-users/10-bryan.sh, modules/20-users/20-amazeeio.sh</files>
  <action>
Run bash syntax validation on both modified files:
- bash -n modules/20-users/10-bryan.sh
- bash -n modules/20-users/20-amazeeio.sh

Both must return 0 (no syntax errors).
  </action>
  <verify>
    <automated>bash -n modules/20-users/10-bryan.sh && bash -n modules/20-users/20-amazeeio.sh && echo "PASS" || echo "FAIL"</automated>
  </verify>
  <done>Both scripts pass bash syntax validation</done>
</task>

</tasks>

<verification>
- [ ] BRYAN_MOBILE_SSH_KEY constant exists in 10-bryan.sh
- [ ] Second user_create_with_ssh call for mobile key in 10-bryan.sh
- [ ] AMAZEEIO_MOBILE_SSH_KEY constant exists in 20-amazeeio.sh
- [ ] Second user_create_with_ssh call for mobile key in 20-amazeeio.sh
- [ ] Both scripts pass `bash -n` validation
</verification>

<success_criteria>
Both user modules updated with mobile SSH key support, scripts syntactically valid.
</success_criteria>

<output>
After completion, run the scripts to apply mobile SSH keys to both users.
</output>
