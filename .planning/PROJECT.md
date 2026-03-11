# Brybuntu Server Setup

## What This Is

A bash-based automation tool that transforms a fresh Ubuntu 24.04.3 LTS server into a ready-to-use development server for SSH-style development. Uses a modular architecture with ordered script execution from subdirectories.

## Current State

**Shipped:** v2.1 DGXC User Addition (2026-03-11)

Three admin users (bryan, amazeeio, dgxc) with full SSH access, passwordless sudo, and LazyVim development environment. Includes Node.js, Opencode CLI, Neovim, and essential development tools.

## Core Value

New Ubuntu server → SSH-ready development environment in one command, with modular components that can be added or removed.

## Requirements

### Validated (v2.1 Shipped)

- ✓ Modular script architecture with numbered execution — v2.0
- ✓ "bryan" user creation with SSH keys and sudo — v2.0
- ✓ "amazeeio" user creation with SSH keys and sudo — v2.0
- ✓ Development environment with Node.js, Neovim, LazyVim — v2.0
- ✓ "dgxc" user with identical configuration — v2.1

### Active (Next Milestone)

(None defined — start next milestone to add requirements)

## Context

- **Target environment:** Fresh Ubuntu 24.04.3 LTS server
- **Execution style:** SSH-based remote development
- **Users:** Three admin users (bryan, amazeeio, dgxc) with full sudo access
- **Tech stack:** Pure bash, 1,774 LOC
- **Modules:** 20+ installation scripts across 7 categories

## Constraints

- **Tech stack:** Pure bash, Ubuntu 24.04.3 LTS
- **Execution:** Must work on brand new server with only root access
- **Security:** SSH key auth only, random passwords, passwordless sudo
- **Modularity:** Components must be addable/removable via subdirectory structure

## Key Decisions

| Decision | Rationale | Outcome |
|----------|-----------|---------|
| Numbered script execution | Clear ordering without complex dependency management | ✓ Good |
| Random passwords + SSH keys | Security best practice | ✓ Good |
| Passwordless sudo via sudoers.d | Unattended development workflow | ✓ Good |
| Modular library pattern (lib/*.sh) | Reusable functions | ✓ Good |
| AppImage for Neovim | Easier version management | ✓ Good |

---
*Last updated: 2026-03-11 after v2.1 milestone completion*
