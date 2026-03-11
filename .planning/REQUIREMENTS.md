# Requirements: Brybuntu Server Setup

**Defined:** 2025-03-10
**Core Value:** New Ubuntu server → SSH-ready development environment in one command, with modular components

## v1 Requirements

### Core Infrastructure

- [x] **CORE-01**: Modular script architecture with numbered execution (10-*.sh, 20-*.sh, etc.)
- [x] **CORE-02**: Main orchestrator script that discovers and executes modules in order
- [x] **CORE-03**: Shared library for common functions (logging, error handling, idempotency checks)
- [x] **CORE-04**: Idempotent operations (safe to re-run without errors)

### System Setup

- [x] **SYS-01**: Run `apt update` before any package operations
- [x] **SYS-02**: Install kitty-terminfo package
- [x] **SYS-03**: Error handling with explicit checks (not relying solely on `set -e`)

### User Management

- [x] **USER-01**: Create "bryan" user if not exists using `adduser`
- [x] **USER-02**: Set random password for "bryan" user
- [x] **USER-03**: Create "/home/bryan/.ssh" directory with correct permissions (700)
- [x] **USER-04**: Add SSH public key to "/home/bryan/.ssh/authorized_keys" with correct permissions (600)
- [x] **USER-05**: Create "amazeeio" user if not exists using `adduser`
- [x] **USER-06**: Set random password for "amazeeio" user
- [x] **USER-07**: Create "/home/amazeeio/.ssh" directory with correct permissions (700)
- [x] **USER-08**: Add SSH public key to "/home/amazeeio/.ssh/authorized_keys" with correct permissions (600)

### Privilege Configuration

- [x] **SUDO-01**: Create "/etc/sudoers.d/bryan" with "bryan ALL=(ALL) NOPASSWD: ALL"
- [x] **SUDO-02**: Create "/etc/sudoers.d/amazeeio" with "amazeeio ALL=(ALL) NOPASSWD: ALL"
- [x] **SUDO-03**: Validate sudoers syntax with `visudo -c` before installing
- [x] **SUDO-04**: Set correct permissions on sudoers.d files (440)

## v2 Requirements (Completed)

### Development Environment

- [x] **DEV-01**: Install Node.js LTS (v20.x or later) system-wide
- [x] **DEV-02**: Install Opencode CLI globally via npm
- [x] **DEV-03**: Install Neovim v0.11.6 via AppImage extraction
- [x] **DEV-04**: Create development library (lib/dev.sh) with reusable functions
- [x] **DEV-05**: Configure LazyVim for "bryan" user with starter template
- [x] **DEV-06**: Configure LazyVim for "amazeeio" user with starter template
- [x] **DEV-07**: Set correct ownership on all Neovim configurations
- [x] **DEV-08**: Ensure idempotent installations (no duplicates on re-run)

### Future v2+ Requirements (Not Implemented)

#### SSH Hardening

- **SSH-01**: Disable password authentication
- **SSH-02**: Enforce Ed25519 key type
- **SSH-03**: Change default SSH port (optional)
- **SSH-04**: Configure fail2ban for brute force protection

#### Additional Components

- **COMP-01**: Docker installation module
- **COMP-02**: Development tools installation (git, curl, wget, etc.)
- **COMP-03**: Dotfiles management integration

#### Operational

- **OPS-01**: Dry-run mode (show what would be done without executing)
- **OPS-02**: Configuration file support (not hardcoded values)
- **OPS-03**: Rollback capability on failure
- **OPS-04**: Comprehensive logging to file

## Out of Scope

| Feature | Reason |
|---------|--------|
| GUI/desktop environment | SSH-only development server per PROJECT.md |
| Multi-server orchestration | Use Ansible/Salt for fleet management |
| Secrets management | Out of scope, use proper secrets manager |
| Firewall configuration | Handled at infrastructure level, not by this tool |
| Password SSH authentication | Security anti-pattern, keys only |
| Cloud-init integration | Tool is for any Ubuntu server, not cloud-specific |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| CORE-01 | Phase 1 | Complete |
| CORE-02 | Phase 1 | Complete |
| CORE-03 | Phase 1 | Complete |
| CORE-04 | Phase 1 | Complete |
| SYS-01 | Phase 1 | Complete |
| SYS-02 | Phase 1 | Complete |
| SYS-03 | Phase 1 | Complete |
| USER-01 | Phase 2 | Complete |
| USER-02 | Phase 2 | Complete |
| USER-03 | Phase 2 | Complete |
| USER-04 | Phase 2 | Complete |
| USER-05 | Phase 2 | Complete |
| USER-06 | Phase 2 | Complete |
| USER-07 | Phase 2 | Complete |
| USER-08 | Phase 2 | Complete |
| SUDO-01 | Phase 3 | Complete |
| SUDO-02 | Phase 3 | Complete |
| SUDO-03 | Phase 3 | Complete |
| SUDO-04 | Phase 3 | Complete |

**Coverage:**
- v1 requirements: 19 total (4 CORE + 3 SYS + 8 USER + 4 SUDO) - All Complete ✓
- v2 requirements: 8 total (8 DEV) - All Complete ✓
- Total: 27/27 mapped
- Unmapped: 0 ✓

### Phase Mapping Summary

| Phase | Requirements | Count | Status |
|-------|--------------|-------|--------|
| Phase 1: Core Infrastructure | CORE-01..04, SYS-01..03 | 7 | ✅ Complete |
| Phase 2: User Management | USER-01..08 | 8 | ✅ Complete |
| Phase 3: Access Control | SUDO-01..04 | 4 | ✅ Complete |
| Phase 4: Development Environment | DEV-01..08 | 8 | ✅ Complete |

---
*Requirements defined: 2025-03-10*
*Last updated: 2026-03-11 - All USER requirements marked complete, added DEV requirements for Phase 4*
