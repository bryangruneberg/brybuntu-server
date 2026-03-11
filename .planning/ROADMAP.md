# Brybuntu Server Setup - Roadmap

**Granularity:** Coarse (3 phases)  
**Defined:** 2025-03-10  
**Core Value:** New Ubuntu server → SSH-ready development environment in one command

---

## Phases

- [x] **Phase 1: Core Infrastructure** - Build execution framework with orchestrator, shared libraries, and idempotent system updates ✓ Complete
- [x] **Phase 2: User Management** - Create bryan and amazeeio users with SSH keys and secure passwords (completed 2026-03-10)
- [x] **Phase 3: Access Control** - Configure passwordless sudo with validated syntax and correct permissions (completed 2026-03-10)
- [x] **Phase 4: Development Environment** - Install Node.js, Opencode CLI, Neovim, and LazyVim for both users ✓ Complete
- [x] **Phase 5: dgxc User Addition** - Create third admin user with identical configuration to bryan/amazeeio (completed 2026-03-11)

---

## Progress

| Phase | Plans Complete | Status | Completed |
|-------|----------------|--------|-----------|
| 1. Core Infrastructure | 2/2 | Complete    | 2026-03-10 |
| 2. User Management | 2/2 | Complete    | 2026-03-10 |
| 3. Access Control | 2/2 | Complete    | 2026-03-10 |
| 4. Development Environment | 2/2 | Complete | 2026-03-10 |
| 5. dgxc User Addition | 1/1 | Complete   | 2026-03-11 |

---

## Phase Details

### Phase 1: Core Infrastructure

**Goal:** Establish the execution framework, logging system, and core automation patterns that enable safe, repeatable server configuration.

**Depends on:** Nothing (first phase)

**Requirements:** CORE-01, CORE-02, CORE-03, CORE-04, SYS-01, SYS-02, SYS-03

**Success Criteria** (what must be TRUE):

1. **install.sh exists and can be executed** - User can run `./install.sh` from the project root
2. **Script discovers and executes modules in order** - Numbered scripts (10-*.sh, 20-*.sh) run sequentially based on filename
3. **Shared library provides logging and error handling** - Common functions available via `source lib/common.sh`
4. **Operations are idempotent** - Running install.sh multiple times produces same result without errors
5. **System updates run automatically** - `apt update` executes before any package operations, kitty-terminfo installs successfully

**Plans:** 2/2 plans complete

Plans:
- [x] `01-01-PLAN.md` — Create shared library (lib/common.sh) and main orchestrator (install.sh) ✓ Completed 2026-03-10
- [x] `01-02-PLAN.md` — Create system modules (apt update, kitty-terminfo) with idempotency verification ✓ Completed 2026-03-10

---

### Phase 2: User Management

**Goal:** Create two admin users (bryan, amazeeio) with secure random passwords and SSH key access for remote development.

**Depends on:** Phase 1

**Requirements:** USER-01, USER-02, USER-03, USER-04, USER-05, USER-06, USER-07, USER-08

**Success Criteria** (what must be TRUE):

1. **"bryan" user exists with home directory** - User can SSH as bryan@server
2. **"bryan" user has SSH key access** - SSH connection succeeds without password using provided Ed25519 key
3. **"bryan" user has random password** - Password is cryptographically random and displayed to operator
4. **"amazeeio" user exists with SSH key access** - Same criteria as bryan user
5. **SSH directories have correct permissions** - .ssh directory is 700, authorized_keys is 600

**Plans:** 2/2 plans complete

Plans:
- [x] `02-01-PLAN.md` — Create user library (lib/user.sh) and bryan user module (modules/20-users/10-bryan.sh) ✓ Completed 2026-03-10
- [x] `02-02-PLAN.md` — Create amazeeio user module and test infrastructure (tests/test_user_management.bats) ✓ Completed 2026-03-10

---

### Phase 3: Access Control

**Goal:** Configure passwordless sudo for both admin users with validated, secure sudoers configuration.

**Depends on:** Phase 2

**Requirements:** SUDO-01, SUDO-02, SUDO-03, SUDO-04

**Success Criteria** (what must be TRUE):

1. **bryan has passwordless sudo** - Running `sudo whoami` as bryan returns "root" without password prompt
2. **amazeeio has passwordless sudo** - Same sudo access as bryan user
3. **Sudoers syntax is validated before installation** - visudo -c passes before any sudoers.d file is installed
4. **Sudoers files have correct permissions** - Files in /etc/sudoers.d/ are mode 440 (readable by root only)
5. **Both users can complete full workflow** - Either user can SSH in, run sudo commands without password

**Plans:** 2/2 plans complete

Plans:
- [x] `03-01-PLAN.md` — Create sudo library (lib/sudo.sh) and bryan sudoers module (modules/30-sudo/10-bryan-sudo.sh) ✓ Completed 2026-03-10
- [x] `03-02-PLAN.md` — Create amazeeio sudoers module (modules/30-sudo/20-amazeeio-sudo.sh) ✓ Completed 2026-03-10

---

## Requirement Coverage

| Requirement | Phase | Status |
|-------------|-------|--------|
| CORE-01 | Phase 1 | Complete |
| CORE-02 | Phase 1 | Complete |
| CORE-03 | Phase 1 | Complete |
| CORE-04 | Phase 1 | Complete |
| SYS-01 | Phase 1 | Complete |
| SYS-02 | Phase 1 | Complete |
| SYS-03 | Phase 1 | Complete |
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

**Coverage:** 19/19 v1 requirements mapped ✓

---

## Dependencies

```
Phase 1 → Phase 2 → Phase 3
```

**Dependency rationale:**
- Phase 2 requires Phase 1 because user creation scripts depend on shared libraries and logging
- Phase 3 requires Phase 2 because sudo configuration requires users to exist

---

### Phase 4: Development Environment

**Goal:** Install modern development tools (Node.js, Opencode CLI, Neovim, LazyVim) for both admin users.

**Depends on:** Phase 3

**Requirements:** DEV-01, DEV-02, DEV-03, DEV-04, DEV-05, DEV-06, DEV-07, DEV-08

**Success Criteria** (what must be TRUE):

1. **Node.js LTS installed system-wide** - `node --version` returns v20.x or later
2. **Opencode CLI installed globally** - `opencode --version` works for all users
3. **Neovim v0.11.6 installed** - `nvim --version` shows correct version
4. **LazyVim configured for bryan** - `~bryan/.config/nvim/` exists with starter config
5. **LazyVim configured for amazeeio** - `~amazeeio/.config/nvim/` exists with starter config
6. **Idempotent installations** - Re-running install.sh doesn't create duplicates
7. **Proper permissions** - All configs owned by respective users

**Plans:** 2/2 plans complete

Plans:
- [x] `04-01-PLAN.md` — Install Node.js LTS and Opencode CLI (modules/40-dev/10-node.sh, 20-opencode.sh) ✓ Completed 2026-03-10
- [x] `04-02-PLAN.md` — Install Neovim and LazyVim for both users (modules/40-dev/30-neovim.sh, 40-lazyvim.sh) ✓ Completed 2026-03-10

---

## Success Criteria Validation

Each phase's success criteria are:
- **Observable**: Can be verified by running commands or checking file existence
- **User-centric**: Described from operator perspective, not implementation details
- **Testable**: Pass/fail conditions are unambiguous

---

### Phase 5: dgxc User Addition

**Goal:** Create a third admin user "dgxc" with identical configuration to bryan and amazeeio, enabling SSH access with passwordless sudo and LazyVim development environment.

**Depends on:** Phase 4 (development environment libraries must exist)

**Requirements:** DGXC-01, DGXC-02, DGXC-03, DGXC-04, DGXC-05, DGXC-06, DGXC-07, DGXC-08

**Success Criteria** (what must be TRUE):

1. **dgxc user exists with home directory** - `id dgxc` returns user info, `/home/dgxc/` exists
2. **dgxc user has SSH key access** - SSH connection as dgxc@server succeeds using Ed25519 key without password
3. **dgxc user has random password** - Password was generated and displayed during creation (stored securely)
4. **dgxc has passwordless sudo access** - Running `sudo whoami` as dgxc returns "root" without password prompt
5. **SSH directories have correct permissions** - `/home/dgxc/.ssh` is mode 700, `authorized_keys` is mode 600
6. **LazyVim is configured for dgxc** - `~dgxc/.config/nvim/` exists with starter config, Neovim loads LazyVim on first run

**Plans:** 1/1 plans complete ✓

Plans:
- [x] `05-01-PLAN.md` — Create dgxc user module, sudo configuration, and LazyVim setup (modules/20-users/15-dgxc.sh, modules/30-sudo/15-dgxc-sudo.sh, modules/40-dev/45-dgxc-lazyvim.sh) ✓ Completed 2026-03-11

---

## Requirement Coverage

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
| DEV-01 | Phase 4 | Complete |
| DEV-02 | Phase 4 | Complete |
| DEV-03 | Phase 4 | Complete |
| DEV-04 | Phase 4 | Complete |
| DEV-05 | Phase 4 | Complete |
| DEV-06 | Phase 4 | Complete |
| DEV-07 | Phase 4 | Complete |
| DEV-08 | Phase 4 | Complete |
| DGXC-01 | Phase 5 | Pending |
| DGXC-02 | Phase 5 | Pending |
| DGXC-03 | Phase 5 | Pending |
| DGXC-04 | Phase 5 | Pending |
| DGXC-05 | Phase 5 | Pending |
| DGXC-06 | Phase 5 | Pending |
| DGXC-07 | Phase 5 | Pending |
| DGXC-08 | Phase 5 | Pending |

**Coverage:** 35/35 total requirements mapped (27 complete + 8 pending) ✓

---

## Dependencies

```
Phase 1 → Phase 2 → Phase 3 → Phase 4 → Phase 5
```

**Dependency rationale:**
- Phase 2 requires Phase 1 because user creation scripts depend on shared libraries and logging
- Phase 3 requires Phase 2 because sudo configuration requires users to exist
- Phase 4 requires Phase 3 because development tools installation requires sudo access
- Phase 5 requires Phase 4 because LazyVim configuration depends on development libraries and Neovim installation

---

*Last updated: 2026-03-11 - Added Phase 5 for dgxc user addition milestone*
