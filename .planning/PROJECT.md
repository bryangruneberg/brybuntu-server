# Brybuntu Server Setup

## What This Is

A bash-based automation tool that transforms a fresh Ubuntu 24.04.3 LTS server into a ready-to-use development server for SSH-style development. Uses a modular architecture with ordered script execution from subdirectories.

## Core Value

New Ubuntu server → SSH-ready development environment in one command, with modular components that can be added or removed.

## Requirements

### Validated (v2.0 Shipped)

- Modular script architecture with numbered execution ✓
- "bryan" user creation with SSH keys and sudo ✓
- "amazeeio" user creation with SSH keys and sudo ✓
- Development environment with Node.js, Neovim, LazyVim ✓

### Active (v2.1 - Current Milestone)

- [ ] "dgxc" user creation with same config as bryan/amazeeio
- [ ] SSH key access for dgxc user
- [ ] Passwordless sudo for dgxc user
- [ ] LazyVim configuration for dgxc user

## Current Milestone: v2.1 "DGXC User Addition"

**Goal:** Add a third admin user "dgxc" with identical configuration to bryan and amazeeio.

**Target features:**
- User creation with home directory and random password
- SSH key access (Ed25519) - same key pattern as other users
- Passwordless sudo privileges
- LazyVim development environment
- Consistent with existing bryan/amazeeio patterns

### Out of Scope

- GUI/desktop environment setup — SSH-only development server
- Docker/container orchestration — may be added as module later
- Application-specific configurations (Node, Python, etc.) — future modules
- Firewall/security hardening beyond basic SSH setup — defer to security module

## Context

Target environment: Fresh Ubuntu 24.04.3 LTS server
Execution style: SSH-based remote development
User requirements: Two admin users (bryan, amazeeio) with full sudo access
SSH key: ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKt9pdXZ/aI31oyRrCc7ER8pfTOcS3r04xVnEOmEjhss bryan@bryarchy

## Constraints

- **Tech stack**: Pure bash, Ubuntu 24.04.3 LTS
- **Execution**: Must work on brand new server with only root access
- **Security**: SSH key auth only, random passwords, passwordless sudo
- **Modularity**: Components must be addable/removable via subdirectory structure

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Numbered script execution (10-*.sh, 20-*.sh, etc.) | Clear ordering without complex dependency management | ✓ Good |
| Random passwords + SSH keys | Security best practice for automated server setup | ✓ Good |
| Passwordless sudo via sudoers.d | Unattended development workflow | ✓ Good |
| Modular library pattern (lib/*.sh) | Reusable functions for user management, sudo, dev tools | ✓ Good |
| AppImage for Neovim distribution | Easier version management and upgrade path | ✓ Good |

---
*Last updated: 2026-03-11 - Starting v2.1 milestone for dgxc user*
