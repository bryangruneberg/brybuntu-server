# Brybuntu Server Setup

## What This Is

A bash-based automation tool that transforms a fresh Ubuntu 24.04.3 LTS server into a ready-to-use development server for SSH-style development. Uses a modular architecture with ordered script execution from subdirectories.

## Current State

**Shipped:** v2.2 Docker Development Environment (2026-03-13)

Complete Docker containerization platform with development tooling for all three admin users (bryan, amazeeio, dgxc). Includes Docker Engine, Compose, lazydocker, ctop, dive, BuildKit/buildx, and hadolint for comprehensive container development workflows.

## Core Value

New Ubuntu server → SSH-ready development environment in one command, with modular components that can be added or removed.

## Requirements

### Validated (v2.2 Shipped)

- ✓ Modular script architecture with numbered execution — v2.0
- ✓ "bryan" user creation with SSH keys and sudo — v2.0
- ✓ "amazeeio" user creation with SSH keys and sudo — v2.0
- ✓ Development environment with Node.js, Neovim, LazyVim — v2.0
- ✓ "dgxc" user with identical configuration — v2.1
- ✓ Docker Engine with daemon configuration — v2.2
- ✓ Docker Compose plugin — v2.2
- ✓ lazydocker TUI for container management — v2.2
- ✓ ctop for container monitoring — v2.2
- ✓ dive for image layer analysis — v2.2
- ✓ BuildKit/buildx for advanced builds — v2.2
- ✓ hadolint for Dockerfile linting — v2.2

### Future Milestones

- [ ] Additional container security scanning (trivy)
- [ ] Registry tools (skopeo, regctl)
- [ ] Kubernetes tooling (kubectl, k9s, helm)

## Context

- **Target environment:** Fresh Ubuntu 24.04.3 LTS server
- **Execution style:** SSH-based remote development
- **Users:** Three admin users (bryan, amazeeio, dgxc) with full sudo access
- **Tech stack:** Pure bash, ~2,400 LOC
- **Modules:** 25+ installation scripts across 8 categories

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
| GitHub releases for Docker tools | Latest versions, consistent pattern | ✓ Good |
| GitHub API for version detection | Fixes 404 errors from /latest/download/ endpoint | ✓ Good |

---
*Last updated: 2026-03-13 after v2.2 milestone completion*
