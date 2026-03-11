# Quick Task 4: Generate SSH keys for root, bryan, and amazeeio

**Task:** 4-generate-ssh-keys-for-root-bryan-and-ama  
**Created:** 2026-03-11  
**Mode:** quick

---

## Objective

Generate Ed25519 SSH keys for root, bryan, and amazeeio users with no passphrase, stored in standard locations (~/.ssh/id_ed25519).

## Tasks

### Task 1: Create SSH key generation module

**Files:**
- `modules/60-ssh-keys/10-generate-ssh-keys.sh` (new module)

**Action:**
Create a module that generates SSH keys for all three users:
1. For each user (root, bryan, amazeeio):
   - Get user's home directory (use /root for root, /home/username for others)
   - Check if ~/.ssh/id_ed25519 already exists (idempotency)
   - Ensure ~/.ssh directory exists with correct permissions (700)
   - Generate ed25519 key pair with no passphrase: `ssh-keygen -t ed25519 -N "" -f ~/.ssh/id_ed25519`
   - Set correct ownership (user:user) and permissions (600 for private key, 644 for public key)
2. Log which keys were created vs skipped

**Verify:**
- `ls -la /root/.ssh/` shows id_ed25519 and id_ed25519.pub
- `ls -la /home/bryan/.ssh/` shows id_ed25519 and id_ed25519.pub  
- `ls -la /home/amazeeio/.ssh/` shows id_ed25519 and id_ed25519.pub
- All private keys have permissions 600, public keys 644
- Private keys owned by respective users

**Done:**
SSH keys generated for all three users (or skipped if already exist).

---

## Notes

- All operations are idempotent (check before create)
- Follows existing module patterns from modules/50-tools/
- Uses lib/common.sh for logging and error handling
- Root's home is /root, not /home/root
- Need to use `su` or run as each user for proper key generation and ownership
