# Brybuntu Server Setup

## What This Is

A bash-based automation tool that transforms a fresh Ubuntu 24.04.3 LTS server into a ready-to-use development server for SSH-style development. Uses a modular architecture with ordered script execution from subdirectories.

## Core Value

New Ubuntu server → SSH-ready development environment in one command, with modular components that can be added or removed.

## Requirements

### Validated

(None yet — ship to validate)

### Active

- [ ] Modular script architecture (numbered files in subdirectories, executed in order)
- [ ] Early system update and kitty-terminfo installation
- [ ] "bryan" user creation with sudo privileges and SSH key access
- [ ] "amazeeio" user creation with sudo privileges and SSH key access
- [ ] Random password generation for users
- [ ] Sudoers configuration for passwordless sudo

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
| Numbered script execution (10-*.sh, 20-*.sh, etc.) | Clear ordering without complex dependency management | — Pending |
| Random passwords + SSH keys | Security best practice for automated server setup | — Pending |
| Passwordless sudo via sudoers.d | Unattended development workflow | — Pending |

---
*Last updated: 2025-03-10 after initialization*
