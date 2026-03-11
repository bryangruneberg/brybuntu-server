# Quick Task 2: Install Neovim Dependencies

**Task:** 2-install-neovim-dependencies-ripgrep-buil  
**Created:** 2026-03-11  
**Mode:** quick

---

## Objective

Install essential dependencies for Neovim/LazyVim: ripgrep, build-essential, luarocks, imagemagick, lazygit, and fd-find.

## Tasks

### Task 1: Install apt packages (ripgrep, build-essential, luarocks, imagemagick, fd-find)

**Files:**
- `modules/50-tools/10-apt-tools.sh` (new module)

**Action:**
Create a new module that installs apt packages with idempotency checks:
1. Check if each package is already installed using `dpkg -l`
2. Install missing packages: ripgrep, build-essential, luarocks, imagemagick, fd-find
3. Create symlink for fd-find: `ln -s $(which fdfind) /usr/local/bin/fd`

**Verify:**
- `dpkg -l | grep -E "ripgrep|build-essential|luarocks|imagemagick|fd-find"` shows all packages
- `which fd` returns /usr/local/bin/fd
- `fd --version` works

**Done:**
All apt packages installed and fd symlink created.

---

### Task 2: Install lazygit from GitHub releases

**Files:**
- `modules/50-tools/20-lazygit.sh` (new module)

**Action:**
Create a module that installs lazygit:
1. Check if lazygit is already installed
2. Install curl and tar if not present
3. Download latest release from GitHub:
   ```bash
   LAZYGIT_VERSION=$(curl -s "https://api.github.com/repos/jesseduffield/lazygit/releases/latest" | grep -Po '"tag_name": *"v\K[^"]*')
   curl -Lo lazygit.tar.gz "https://github.com/jesseduffield/lazygit/releases/download/v${LAZYGIT_VERSION}/lazygit_${LAZYGIT_VERSION}_Linux_x86_64.tar.gz"
   tar xf lazygit.tar.gz lazygit
   install lazygit -D -t /usr/local/bin/
   ```
4. Clean up downloaded files

**Verify:**
- `which lazygit` returns /usr/local/bin/lazygit
- `lazygit --version` shows version

**Done:**
Lazygit installed and working.

---

## Execution Order

1. Task 1 (apt packages) - can run anytime
2. Task 2 (lazygit) - can run anytime (independent)

## Notes

- All installations are idempotent (check before install)
- Follows existing module patterns from modules/40-dev/
- Uses lib/common.sh for logging and error handling
