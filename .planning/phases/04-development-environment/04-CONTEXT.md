# Phase 4: Development Environment - Context

**Phase:** 04-development-environment  
**Goal:** Install modern development tools (Node.js, Opencode CLI, Neovim, LazyVim) for both admin users  
**Depends on:** Phase 3 (Access Control)  
**Created:** 2026-03-11 (retroactive documentation)  
**Status:** Complete

---

## Overview

This phase adds modern development tooling to the brybuntu server setup, enabling both admin users (bryan and amazeeio) to have a fully-featured development environment immediately after server provisioning.

## Key Decisions

1. **NodeSource for Node.js**: Using NodeSource repository for LTS installation ensures we get the latest stable Node.js without relying on Ubuntu's potentially outdated packages.

2. **NPM for Opencode**: Opencode CLI is distributed via npm, making it a natural choice for global installation.

3. **Neovim via AppImage**: Neovim v0.11.6 is installed by extracting the official AppImage to `/opt/nvim/` and symlinking to `/usr/local/bin/`. This avoids building from source while getting the latest version.

4. **LazyVim per-user**: Each user gets their own LazyVim configuration cloned from the starter template. This allows personalization while providing a solid default setup.

5. **Idempotent installations**: All modules check for existing installations before proceeding, ensuring safe re-runs.

## Components

### Libraries
- `lib/dev.sh` - Shared functions for development environment setup
  - `install_lazyvim_for_user()` - Clones LazyVim starter and configures for a specific user

### Modules
- `modules/40-dev/10-node.sh` - Installs Node.js LTS via NodeSource
- `modules/40-dev/20-opencode.sh` - Installs Opencode CLI globally via npm
- `modules/40-dev/30-neovim.sh` - Installs Neovim v0.11.6 via AppImage
- `modules/40-dev/40-lazyvim.sh` - Configures LazyVim for both bryan and amazeeio users

## Success Criteria Validation

All success criteria have been validated:

1. ✅ Node.js LTS installed - `node --version` returns v20.x+
2. ✅ Opencode CLI installed - `opencode --version` works globally
3. ✅ Neovim v0.11.6 installed - `nvim --version` shows correct version
4. ✅ LazyVim for bryan - `~bryan/.config/nvim/` exists
5. ✅ LazyVim for amazeeio - `~amazeeio/.config/nvim/` exists
6. ✅ Idempotent - Re-running doesn't create duplicates
7. ✅ Proper permissions - All configs owned by respective users

---
*Context captured after implementation completion*
