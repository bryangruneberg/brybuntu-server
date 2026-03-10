# Project Research Summary

**Project:** Brybuntu Server Setup  
**Domain:** Bash-based Ubuntu 24.04.3 LTS Server Automation  
**Researched:** 2025-03-10  
**Confidence:** HIGH

---

## Executive Summary

Brybuntu is a **bash-based server automation tool** targeting Ubuntu 24.04.3 LTS servers, designed to replace manual setup with modular, numbered scripts that execute in order. Based on research of established tools like Ansible, cloud-init, and donnemartin/dev-setup, the recommended approach is a **pure bash architecture** using modern Bash 5.2+ with strict mode (`set -euo pipefail`), modular script organization with numbered directories (10-system/, 20-users/, 30-network/), and shared utility libraries for common operations.

The research confirms that for single-server Ubuntu automation, bash remains the optimal choice over complex configuration management tools like Ansible or Chef. The key insight: successful bash automation tools (Homebrew installer, Oh My Zsh, s6-overlay) follow a **layered architecture** with ordered execution, fail-fast error handling, and idempotent operations. The stack should use `adduser` (not `useradd`), Ed25519 SSH keys, `sudoers.d/` for privilege management, and ShellCheck for quality assurance.

**Key risks identified:** (1) SSH lockout during configuration changes, (2) sudoers syntax errors causing complete root lockout, and (3) non-idempotent scripts that fail on re-runs. Mitigation strategies include config validation (`sshd -t`, `visudo -c`), check-before-create patterns, and comprehensive error handling with explicit exit code checking rather than relying solely on `set -e`.

---

## Key Findings

### Recommended Stack

The research establishes a clear stack for Ubuntu 24.04 LTS server automation based on official Ubuntu Server documentation and industry best practices from Google Shell Style Guide and ShellCheck.

**Core technologies:**
- **Bash 5.2+**: Primary scripting language — Ubuntu 24.04 ships 5.2.21, modern features available
- **adduser (not useradd)**: User creation — Ubuntu/Debian explicitly recommends this higher-level tool
- **Ed25519**: SSH key algorithm — shorter, faster, more secure than RSA; industry standard for 2025
- **sudoers.d/**: Privilege configuration — modular, manageable, avoids editing /etc/sudoers directly
- **systemctl**: Service management — native systemd interface for Ubuntu 24.04
- **ShellCheck**: Static analysis — industry standard used by Google, GitHub; catches security and logic issues

**Critical version notes:**
- Ubuntu 24.04 uses traditional `sudo` (1.9.15p5); `sudo-rs` (Rust rewrite) comes in 25.10+
- OpenSSH 9.6+ supports modular config via `sshd_config.d/`
- Use `DEBIAN_FRONTEND=noninteractive` for automated apt operations

### Expected Features

Based on analysis of cloud-init, Ansible, and similar tools, users expect certain baseline capabilities while competitive differentiators focus on developer experience.

**Must have (table stakes):**
- **System update** — Security baseline; all provisioning tools do this first
- **User creation with SSH keys** — Core value proposition; specific users needed
- **Passwordless sudo configuration** — Developer workflow requirement
- **SSH key-based authentication** — Industry standard; password auth disabled
- **Idempotent execution** — Running multiple times produces same result
- **Error handling and logging** — Essential for debugging automation failures

**Should have (competitive):**
- **Modular architecture** — Users can add/remove components (donnemartin/dev-setup pattern)
- **Numbered script execution** — Clear ordering without complex dependency management
- **Random password generation** — Security without manual password management
- **Re-runnable without side effects** — Safe to run on already-configured servers
- **Configuration validation** — Verify Ubuntu version, root access, network before running

**Defer (v2+):**
- **Dry-run mode** — Complex in bash; use logging instead
- **Environment-specific configs** — Start with single use-case
- **Dotfiles management** — Use chezmoi for this; out of scope
- **Docker/container setup** — Separate concern; can be added as optional module

**Never build:**
- Password authentication for SSH (security anti-pattern)
- GUI/desktop environment setup (explicitly out of scope per PROJECT.md)
- Multi-server orchestration (Ansible territory)
- Web dashboard or UI (tool scope is CLI automation)

### Architecture Approach

Research of mature bash tools (Homebrew, Oh My Zsh, s6-overlay) reveals a consistent **layered, modular architecture** with ordered execution.

**Major components:**

1. **Entry Point (`install.sh`)** — Orchestrator that validates environment, discovers modules via filesystem scan, executes in order, aggregates errors, generates summary report

2. **Module Execution Layer (`XX-category/YY-*.sh`)** — Specific automation tasks organized by concern:
   - `10-system/` — System updates, package installation
   - `20-users/` — User creation, password generation
   - `30-network/` — SSH configuration, sudoers setup
   - Execution order: numbered scripts within directories, numbered directories globally

3. **Shared Utilities Layer (`lib/*.sh`)** — Common functionality:
   - `lib/common.sh` — Logging, error handling, validation
   - `lib/user.sh` — User creation helpers
   - `lib/security.sh` — Password generation, SSH key handling
   - Idempotent loading guards against double-sourcing

4. **Data & State Layer** — Runtime working directory (`/tmp/brybuntu/`), execution logs (`/var/log/brybuntu/`), user-specific state if needed

**Key patterns:**
- **Ordered execution with numbered scripts** — Visual ordering without complex dependency resolver
- **Fail-fast with cleanup** — `set -euo pipefail` with trap handlers for cleanup
- **Configuration as data** — SSH keys, usernames stored in config files, not hardcoded
- **Explicit prerequisite checking** — Scripts validate dependencies rather than assuming state

### Critical Pitfalls

Research identified 8 critical pitfalls specific to bash server automation, with Phase 1 (Core Infrastructure) requiring mitigation for most.

1. **Non-Idempotent Scripts** — Check before creating (`if ! id "$user" &>/dev/null`), check before appending to config files, use `dpkg -l` before `apt install`

2. **Missing Error Handling** — Don't rely solely on `set -e` (has complex exception rules per BashFAQ/105); use explicit error checking: `command || { echo "Failed"; exit 1; }`

3. **Word Splitting and Globbing** — **Always quote variable expansions**: `"$var"` not `$var`; ShellCheck SC2086 catches this

4. **SSH Lockout During Configuration** — Always test with `sshd -t` before reloading; use `systemctl reload` not `restart`; verify new connection works before closing session

5. **Improper Sudoers Editing** — Syntax errors can lock out all root access; validate with `visudo -c` before installing; use atomic file operations; set `chmod 0440` on sudoers.d files

6. **set -e Misunderstanding** — Doesn't trigger in `if`/`while` tests, `&&`/`||` lists (except last), or pipelines (without pipefail); use explicit error checking instead

7. **Subshell Variable Scope** — Variables set in pipelines don't persist; use `shopt -s lastpipe` (bash 4.2+) or file descriptor redirection `< <(command)`

8. **Not Checking Root Privileges** — Validate at script start: `if [[ $EUID -ne 0 ]]; then exit 1; fi`; avoid mixing root/non-root operations

---

## Implications for Roadmap

Based on research, suggested phase structure:

### Phase 1: Foundation & Core System
**Rationale:** Must establish execution framework, logging, and validation before any system modifications. Critical pitfalls (idempotency, error handling, SSH lockout) must be addressed here.

**Delivers:**
- `install.sh` orchestrator with module discovery
- `lib/common.sh` with logging and error handling
- `lib/security.sh` with password generation
- `10-system/10-update.sh` — System update (idempotent)
- Configuration management structure

**Addresses:** System update, error handling, logging, idempotent execution, configuration validation

**Avoids:** Non-idempotent scripts (Pitfall 1), missing error handling (Pitfall 2), word splitting (Pitfall 3)

**Research flag:** STANDARD PATTERNS — Well-documented bash patterns, ShellCheck integration

### Phase 2: User Management
**Rationale:** Users must exist before SSH keys can be deployed or sudo access granted. Depends on Phase 1 libraries.

**Delivers:**
- `lib/user.sh` — User creation helpers using `adduser`
- `20-users/10-bryan.sh` — Create bryan user with SSH key
- `20-users/20-amazeeio.sh` — Create amazeeio user with SSH key
- Random password generation and secure display

**Uses:** Stack elements: adduser, usermod, chpasswd, Ed25519 SSH keys

**Implements:** Architecture components: Module execution layer, user library

**Avoids:** Weak password generation (Pitfall 9), uninitialized variables (Pitfall 12)

**Research flag:** STANDARD PATTERNS — Ubuntu Server docs provide clear user management guidance

### Phase 3: Access Control (SSH & Sudo)
**Rationale:** Security-critical phase that must validate configurations before applying. SSH lockout and sudoers syntax errors are catastrophic failures.

**Delivers:**
- `30-network/10-ssh.sh` — SSH configuration with Ed25519 key deployment
- `30-network/20-sudoers.sh` — Passwordless sudo configuration
- Config validation (`sshd -t`, `visudo -c`)
- Connection testing before completing

**Addresses:** SSH key-based authentication, passwordless sudo

**Avoids:** SSH lockout (Pitfall 7), improper sudoers editing (Pitfall 6), hardcoded paths (Pitfall 15)

**Research flag:** NEEDS RESEARCH — SSH configuration safety patterns, rollback strategies for failed configs

### Phase 4: Validation & Polish
**Rationale:** Final phase ensures the automation is reliable, documented, and ready for use. Testing strategy critical for bash automation.

**Delivers:**
- Integration tests in Docker containers
- Documentation (usage, troubleshooting)
- ShellCheck CI integration
- Final validation script to verify setup

**Addresses:** Re-runnable without side effects, configuration validation

**Research flag:** NEEDS RESEARCH — Testing strategy for bash automation without repeatedly creating servers

### Phase Ordering Rationale

1. **Phase 1 must come first** — Execution framework, logging, and error handling are prerequisites for all other work. Without these, debugging subsequent phases is impossible.

2. **Phase 2 before Phase 3** — SSH keys and sudo configuration require users to exist. Natural dependency chain.

3. **Phase 3 is high-risk** — SSH and sudo are security-critical with catastrophic failure modes (lockout). Must have solid foundation from Phases 1-2 before attempting.

4. **Phase 4 validates everything** — Testing and documentation happen after core functionality exists.

### Research Flags

Phases likely needing deeper research during planning:
- **Phase 3 (Access Control):** SSH lockout prevention strategies, rollback mechanisms for failed configs
- **Phase 4 (Validation):** Testing bash automation without VM sprawl, ShellCheck CI integration patterns

Phases with standard patterns (skip research-phase):
- **Phase 1 (Foundation):** Well-documented bash patterns, ShellCheck standard
- **Phase 2 (User Management):** Ubuntu Server docs provide clear guidance on adduser patterns

---

## Confidence Assessment

| Area | Confidence | Notes |
|------|------------|-------|
| Stack | HIGH | Verified with official Ubuntu Server docs, packages.ubuntu.com, Bash manual |
| Features | HIGH | Based on cloud-init, Ansible patterns; multiple verified sources agree |
| Architecture | MEDIUM-HIGH | Derived from Homebrew, Oh My Zsh, s6-overlay patterns; established best practices |
| Pitfalls | HIGH | BashFAQ/105, BashPitfalls wiki, ShellCheck documentation; comprehensive sources |

**Overall confidence:** HIGH

The bash automation domain is well-documented with established patterns. Ubuntu 24.04 LTS is a stable, well-understood target. The main uncertainty lies in testing strategies for bash automation (Phase 4), which is a common challenge across the domain.

### Gaps to Address

- **Idempotency verification:** Need to test each script's behavior when run multiple times; should be part of Phase 4 testing strategy
- **Error recovery:** Define behavior when partial setup fails mid-execution; document manual rollback procedures
- **Testing without VM sprawl:** How to validate automation without repeatedly creating Ubuntu servers; Docker containers may not fully replicate SSH/sudo behavior
- **Ubuntu version compatibility:** Current research targets 24.04 LTS specifically; if supporting 22.04 or 25.04+ needed, re-verify package versions and tool availability

---

## Sources

### Primary (HIGH confidence)
- **Ubuntu Server Documentation** — https://ubuntu.com/server/docs — User management, OpenSSH configuration, verified tool recommendations
- **Bash Reference Manual** — https://www.gnu.org/software/bash/manual/bash.html — Version 5.3, strict mode behavior
- **Google Shell Style Guide** — https://google.github.io/styleguide/shellguide.html — Industry best practices
- **ShellCheck** — https://github.com/koalaman/shellcheck — Static analysis patterns
- **BashFAQ/105** — https://mywiki.wooledge.org/BashFAQ/105 — set -e behavior (critical pitfalls)
- **cloud-init Documentation** — https://cloudinit.readthedocs.io/ — User creation patterns, module system

### Secondary (MEDIUM confidence)
- **s6-overlay** — https://github.com/just-containers/s6-overlay — Init stage patterns, ordered execution
- **donnemartin/dev-setup** — https://github.com/donnemartin/dev-setup — Modular bash architecture
- **Oh My Zsh** — Plugin/modular architecture patterns
- **Homebrew Install** — Multi-platform bash installer patterns

### Tertiary (LOW confidence)
- **NVM** — Installation script patterns (context only)
- **powerlevel10k** — Terminal customization (context only)

---

*Research completed: 2025-03-10*  
*Ready for roadmap: yes*
