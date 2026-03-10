# Requirements: Brybuntu Server Setup

**Defined:** 2025-03-10
**Core Value:** New Ubuntu server → SSH-ready development environment in one command, with modular components

## v1 Requirements

### Core Infrastructure

- [ ] **CORE-01**: Modular script architecture with numbered execution (10-*.sh, 20-*.sh, etc.)
- [ ] **CORE-02**: Main orchestrator script that discovers and executes modules in order
- [ ] **CORE-03**: Shared library for common functions (logging, error handling, idempotency checks)
- [ ] **CORE-04**: Idempotent operations (safe to re-run without errors)

### System Setup

- [ ] **SYS-01**: Run `apt update` before any package operations
- [ ] **SYS-02**: Install kitty-terminfo package
- [ ] **SYS-03**: Error handling with explicit checks (not relying solely on `set -e`)

### User Management

- [ ] **USER-01**: Create "bryan" user if not exists using `adduser`
- [ ] **USER-02**: Set random password for "bryan" user
- [ ] **USER-03**: Create "/home/bryan/.ssh" directory with correct permissions (700)
- [ ] **USER-04**: Add SSH public key to "/home/bryan/.ssh/authorized_keys" with correct permissions (600)
- [ ] **USER-05**: Create "amazeeio" user if not exists using `adduser`
- [ ] **USER-06**: Set random password for "amazeeio" user
- [ ] **USER-07**: Create "/home/amazeeio/.ssh" directory with correct permissions (700)
- [ ] **USER-08**: Add SSH public key to "/home/amazeeio/.ssh/authorized_keys" with correct permissions (600)

### Privilege Configuration

- [ ] **SUDO-01**: Create "/etc/sudoers.d/bryan" with "bryan ALL=(ALL) NOPASSWD: ALL"
- [ ] **SUDO-02**: Create "/etc/sudoers.d/amazeeio" with "amazeeio ALL=(ALL) NOPASSWD: ALL"
- [ ] **SUDO-03**: Validate sudoers syntax with `visudo -c` before installing
- [ ] **SUDO-04**: Set correct permissions on sudoers.d files (440)

## v2 Requirements

### SSH Hardening

- **SSH-01**: Disable password authentication
- **SSH-02**: Enforce Ed25519 key type
- **SSH-03**: Change default SSH port (optional)
- **SSH-04**: Configure fail2ban for brute force protection

### Additional Components

- **COMP-01**: Docker installation module
- **COMP-02**: Development tools installation (git, curl, wget, etc.)
- **COMP-03**: Dotfiles management integration
- **COMP-04**: Firewall (ufw) configuration

### Operational

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
| Complex firewall rules | Basic SSH only for v1 |
| Password SSH authentication | Security anti-pattern, keys only |
| Cloud-init integration | Tool is for any Ubuntu server, not cloud-specific |

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| CORE-01 | Phase 1 | Pending |
| CORE-02 | Phase 1 | Pending |
| CORE-03 | Phase 1 | Pending |
| CORE-04 | Phase 1 | Pending |
| SYS-01 | Phase 1 | Pending |
| SYS-02 | Phase 1 | Pending |
| SYS-03 | Phase 1 | Pending |
| USER-01 | Phase 2 | Pending |
| USER-02 | Phase 2 | Pending |
| USER-03 | Phase 2 | Pending |
| USER-04 | Phase 2 | Pending |
| USER-05 | Phase 2 | Pending |
| USER-06 | Phase 2 | Pending |
| USER-07 | Phase 2 | Pending |
| USER-08 | Phase 2 | Pending |
| SUDO-01 | Phase 3 | Pending |
| SUDO-02 | Phase 3 | Pending |
| SUDO-03 | Phase 3 | Pending |
| SUDO-04 | Phase 3 | Pending |

**Coverage:**
- v1 requirements: 16 total
- Mapped to phases: 16
- Unmapped: 0 ✓

---
*Requirements defined: 2025-03-10*
*Last updated: 2025-03-10 after initial definition*
