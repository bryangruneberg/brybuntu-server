# Quick Task 5: Display SSH public keys and install CLI tools

**Task:** 5-display-ssh-public-keys-and-install-gh-c  
**Created:** 2026-03-11  
**Mode:** quick

---

## Objective

1. Display all three SSH public keys (root, bryan, amazeeio) for easy copy/paste
2. Install GitHub CLI (gh)
3. Install Google Workspace CLI (@googleworkspace/cli)

## Tasks

### Task 1: Create SSH key display module

**Files:**
- `modules/70-utilities/10-display-ssh-keys.sh` (new module)

**Action:**
Create a module that displays SSH public keys:
1. Check if id_ed25519.pub exists for each user (root, bryan, amazeeio)
2. If keys exist, display them with clear labels:
   ```
   === SSH Public Keys for Copy/Paste ===
   
   --- root ---
   ssh-ed25519 AAAAC3NzaC... root@hostname
   
   --- bryan ---
   ssh-ed25519 AAAAC3NzaC... bryan@hostname
   
   --- amazeeio ---
   ssh-ed25519 AAAAC3NzaC... amazeeio@hostname
   ```
3. If a key doesn't exist, show a warning message

**Verify:**
- Script runs without errors
- Public keys are displayed (if they exist)
- Clear separation between different user keys

**Done:**
SSH public keys displayed for copy/paste.

---

### Task 2: Install GitHub CLI (gh)

**Files:**
- `modules/70-utilities/20-github-cli.sh` (new module)

**Action:**
Create a module that installs GitHub CLI:
1. Check if gh is already installed
2. Install dependencies (curl, gnupg)
3. Use official GitHub installation script:
   ```bash
   curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
   chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg
   echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | tee /etc/apt/sources.list.d/github-cli.list > /dev/null
   apt update
   apt install gh -y
   ```
4. Verify installation

**Verify:**
- `which gh` returns a path
- `gh --version` works

**Done:**
GitHub CLI installed.

---

### Task 3: Install Google Workspace CLI

**Files:**
- `modules/70-utilities/30-google-cli.sh` (new module)

**Action:**
Create a module that installs Google Workspace CLI:
1. Check if gws (Google Workspace CLI) is already installed
2. Verify npm is available (from Node.js installation)
3. Install globally: `npm install -g @googleworkspace/cli`
4. Verify installation

**Verify:**
- `which gws` returns a path
- `gws --version` or `gws help` works

**Done:**
Google Workspace CLI installed.

---

## Notes

- All installations are idempotent
- Follows existing module patterns
- Uses lib/common.sh for logging and error handling
- GitHub CLI requires apt repository setup
- Google CLI requires npm (from Node.js installation)
