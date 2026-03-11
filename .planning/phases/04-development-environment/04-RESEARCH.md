# Phase 4: Development Environment - Research

**Phase:** 04-development-environment  
**Created:** 2026-03-11 (retroactive documentation)  
**Status:** Complete

---

## Node.js Installation Research

### Options Considered
1. **Ubuntu apt repository** - Often outdated (may ship v12-v18 when v20 is current)
2. **NodeSource repository** - Official LTS builds, well-maintained
3. **NVM (Node Version Manager)** - Per-user installation, adds complexity
4. **Manual binary download** - Requires manual updates

### Decision: NodeSource
- Provides latest LTS (v20.x at time of implementation)
- System-wide installation accessible to all users
- Maintained by Node.js community
- Simple setup script approach

### Implementation Pattern
```bash
# Download and execute NodeSource setup
 curl -fsSL https://deb.nodesource.com/setup_20.x | bash -
 apt-get install -y nodejs
```

---

## Opencode CLI Research

### Distribution Method
- Published to npm registry as `opencode`
- Global installation: `npm install -g opencode`

### Dependencies
- Requires Node.js (satisfied by 10-node.sh module)
- No additional system dependencies

---

## Neovim Installation Research

### Options Considered
1. **Ubuntu apt repository** - Often outdated (v0.6-0.7 when v0.11 is current)
2. **Build from source** - Time-consuming, requires build dependencies
3. **AppImage extraction** - Official builds, no runtime dependencies
4. **Snap/Flatpak** - Adds complexity, sandboxing issues

### Decision: AppImage Extraction
- Official stable builds from neovim.io
- No build time or dependencies
- Extract to `/opt/nvim/` for system-wide access
- Symlink `/usr/local/bin/nvim` for PATH access

### Version Selected
- v0.11.6 (stable at implementation time)
- Provides LuaJIT, treesitter, LSP support

---

## LazyVim Configuration Research

### What is LazyVim?
- Neovim configuration framework built on lazy.nvim plugin manager
- Starter template provides batteries-included IDE-like experience
- Pre-configured LSP, treesitter, fuzzy finder, etc.

### Installation Method
1. Clone starter template to `~/.config/nvim/`
2. Remove `.git` folder to make it user's own config
3. First run installs plugins automatically

### Per-User Installation Rationale
- Each user may want different customizations
- Starter provides solid defaults that work for both
- Allows independent updates and modifications

### Idempotency Consideration
- Check if `~/.config/nvim/` exists before cloning
- Skip if already present to avoid overwriting user customizations

---

## Security Considerations

1. **NodeSource GPG key** - Script downloads and installs official key
2. **npm global installs** - Run as root, accessible to all users
3. **AppImage checksum** - Verify download integrity (future enhancement)
4. **Config permissions** - All user configs owned by respective users (700/600)

---

## Technical Notes

### Module Ordering (40-dev)
- `10-node.sh` - Must run first (Opencode depends on npm)
- `20-opencode.sh` - Depends on Node.js
- `30-neovim.sh` - Independent, can run anytime
- `40-lazyvim.sh` - Must run after Neovim, requires users to exist

### Library Design (lib/dev.sh)
- Source guard pattern (`BRYBUNTU_DEV`)
- Depends on lib/common.sh for logging
- Reusable `install_lazyvim_for_user()` function

---

## References

- NodeSource: https://github.com/nodesource/distributions
- Neovim: https://neovim.io/
- LazyVim: https://www.lazyvim.org/
- Opencode: https://opencode.ai

---
*Research documented after implementation completion*
