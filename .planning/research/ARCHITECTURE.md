# Architecture Patterns: Bash-Based Server Automation

**Project:** Brybuntu Server Setup  
**Domain:** Bash-based server automation tools  
**Researched:** 2025-03-10  
**Confidence:** MEDIUM (based on established patterns from Homebrew, Oh My Zsh, s6-overlay, and CLI best practices)

---

## Recommended Architecture

Based on research of mature bash-based automation tools (Homebrew installer, Oh My Zsh, NVM, s6-overlay), brybuntu-server should adopt a **layered, modular architecture** with ordered execution.

```
┌─────────────────────────────────────────────────────────────────┐
│                        ENTRY POINT                              │
│                    install.sh (orchestrator)                    │
│         - Validates environment and prerequisites               │
│         - Discovers and executes modules in order               │
│         - Handles global error recovery                         │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      MODULE EXECUTION LAYER                     │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐             │
│  │ 10-system/  │  │ 20-users/   │  │ 30-network/ │  ...        │
│  │ 10-update.sh│  │ 10-bryan.sh │  │ 10-ssh.sh   │             │
│  │ 20-kitty.sh │  │ 20-amazeeio │  │ 20-firewall │             │
│  └─────────────┘  └─────────────┘  └─────────────┘             │
│                                                                 │
│  Execution order: 10-*.sh → 20-*.sh → 30-*.sh (within each dir)│
│  Directory order: 10-system → 20-users → 30-network (globally)  │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      SHARED UTILITIES LAYER                     │
│  lib/common.sh        - Logging, error handling, validation     │
│  lib/config.sh        - Configuration management                │
│  lib/user.sh          - User creation helpers                   │
│  lib/security.sh      - Password generation, SSH key handling   │
└─────────────────────────────────────────────────────────────────┘
                              │
                              ▼
┌─────────────────────────────────────────────────────────────────┐
│                      DATA & STATE LAYER                         │
│  /tmp/brybuntu/       - Runtime working directory               │
│  /var/log/brybuntu/   - Execution logs                          │
│  ~/.brybuntu/         - User-specific state (if needed)         │
└─────────────────────────────────────────────────────────────────┘
```

---

## Component Boundaries

| Component | Responsibility | Communicates With |
|-----------|---------------|-------------------|
| **Entry Point** (`install.sh`) | Environment validation, module discovery, execution orchestration, error aggregation | All modules, lib/common.sh |
| **Module Scripts** (`XX-category/YY-*.sh`) | Specific automation tasks (system updates, user creation, etc.) | lib/* utilities, writes to state layer |
| **Common Library** (`lib/common.sh`) | Logging, error handling, prerequisite checks | Used by all modules |
| **Config Library** (`lib/config.sh`) | SSH keys, user definitions, settings management | Used by user/network modules |
| **User Library** (`lib/user.sh`) | User creation, sudoers management, password generation | Used by 20-users/* modules |
| **Security Library** (`lib/security.sh`) | Random password generation, SSH key validation | Used by lib/user.sh |

### Communication Patterns

```
Data Flow Direction:
────────────────────
1. Entry Point → discovers modules by filesystem scan
2. Entry Point → sources lib/common.sh (shared functions)
3. Entry Point → executes modules in order
4. Each module → sources required lib/*.sh files
5. Each module → writes logs to /var/log/brybuntu/
6. Entry Point ← collects exit codes from all modules
7. Entry Point → generates summary report

State Sharing:
─────────────
- Configuration: Environment variables or sourced config file
- Runtime state: /tmp/brybuntu/state.json or similar
- Logs: /var/log/brybuntu/YYYY-MM-DD-HHMMSS/
```

---

## Patterns to Follow

### Pattern 1: Ordered Execution with Numbered Scripts

**What:** Scripts are prefixed with numbers (10-, 20-, 30-) to establish execution order without complex dependency management.

**When to Use:** For simple linear dependencies where later scripts expect earlier ones to have completed.

**Example Structure:**
```
10-system/
  10-update.sh      # Update package lists first
  20-kitty.sh       # Install kitty-terminfo after update

20-users/
  10-bryan.sh       # Create bryan user
  20-amazeeio.sh    # Create amazeeio user (can run parallel to bryan)

30-network/
  10-ssh.sh         # Configure SSH (needs users to exist)
  20-sudoers.sh     # Configure sudoers (needs users to exist)
```

**Rationale:** This is the pattern established in the project requirements and used successfully by s6-overlay's init stages. It provides clear visual ordering without requiring a dependency resolver.

### Pattern 2: Library Sourcing with Idempotent Loading

**What:** Common functions are placed in `lib/` and sourced by scripts. Each library guards against double-sourcing.

**Implementation:**
```bash
# lib/common.sh
if [[ -n "${BRYBUNTU_COMMON_SOURCED:-}" ]]; then
    return 0
fi
BRYBUNTU_COMMON_SOURCED=1

# ... functions ...
```

**When to Use:** For shared functionality used across multiple modules.

### Pattern 3: Fail-Fast with Cleanup

**What:** Scripts use `set -euo pipefail` and define trap handlers for cleanup.

**Implementation (from minimal safe bash template):**
```bash
#!/usr/bin/env bash
set -Eeuo pipefail
trap cleanup SIGINT SIGTERM ERR EXIT

cleanup() {
    trap - SIGINT SIGTERM ERR EXIT
    # Remove temp files, restore state, etc.
}
```

**When to Use:** All executable scripts should use this pattern for safety.

### Pattern 4: Structured Logging

**What:** Consistent logging functions that write to both stdout/stderr and log files.

**Implementation:**
```bash
# lib/common.sh
BRYBUNTU_LOG_DIR="/var/log/brybuntu/$(date +%Y%m%d-%H%M%S)"

log_info() {
    echo "[INFO] $*" | tee -a "$BRYBUNTU_LOG_DIR/install.log"
}

log_error() {
    echo "[ERROR] $*" >&2 | tee -a "$BRYBUNTU_LOG_DIR/install.log" >&2
}
```

**When to Use:** All modules should use these functions instead of raw `echo`.

### Pattern 5: Configuration as Data

**What:** User-specific data (SSH keys, usernames) are stored in a config file, not hardcoded in scripts.

**Implementation:**
```bash
# config/defaults.conf
SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKt9pdXZ/aI31oyRrCc7ER8pfTOcS3r04xVnEOmEjhss bryan@bryarchy"
USERS=("bryan" "amazeeio")
```

**When to Use:** For any data that might change between installations.

---

## Anti-Patterns to Avoid

### Anti-Pattern 1: Implicit Dependencies

**What:** Scripts that assume previous scripts ran without checking.

**Why Bad:** Creates fragile execution that fails mysteriously if run out of order.

**Instead:** Scripts should check prerequisites explicitly:
```bash
# In 20-users/10-bryan.sh
if ! command -v apt-get &>/dev/null; then
    log_error "apt-get not found. Did 10-system/10-update.sh run?"
    exit 1
fi
```

### Anti-Pattern 2: Mutable Global State

**What:** Scripts that modify global variables affecting other scripts.

**Why Bad:** Creates unpredictable interactions between modules.

**Instead:** Use local variables and explicit parameter passing:
```bash
# Good
local username="$1"
create_user "$username"

# Bad
USERNAME="bryan"  # Global mutation
create_user        # Implicitly uses global
```

### Anti-Pattern 3: Silent Failures

**What:** Commands that fail but script continues (missing `set -e` or unchecked return codes).

**Why Bad:** Partial failures lead to inconsistent system state.

**Instead:** Always use `set -euo pipefail` and check critical commands:
```bash
# Good
if ! useradd -m "$username"; then
    log_error "Failed to create user $username"
    exit 1
fi
```

### Anti-Pattern 4: Hardcoded Paths

**What:** Scripts that assume execution from a specific directory.

**Why Bad:** Breaks when run from different working directories.

**Instead:** Calculate script directory dynamically:
```bash
SCRIPT_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" &>/dev/null && pwd -P)
source "$SCRIPT_DIR/../lib/common.sh"
```

---

## Suggested Build Order (Dependencies)

Based on the project requirements, modules should be built in this order:

```
Phase 1: Foundation (Week 1)
├── lib/common.sh (logging, error handling)
├── lib/security.sh (password generation)
├── config/defaults.conf (configuration)
└── install.sh (orchestrator)

Phase 2: Core System (Week 1-2)
├── 10-system/10-update.sh (system update)
└── 10-system/20-kitty.sh (terminfo installation)

Phase 3: User Management (Week 2)
├── lib/user.sh (user creation helpers)
├── 20-users/10-bryan.sh
└── 20-users/20-amazeeio.sh

Phase 4: Access Control (Week 2-3)
├── 30-network/10-ssh.sh (SSH key deployment)
└── 30-network/20-sudoers.sh (passwordless sudo)

Phase 5: Validation & Polish (Week 3)
├── tests/ (validation scripts)
└── docs/ (usage documentation)
```

### Dependency Graph

```
                    ┌─────────────┐
                    │ install.sh  │
                    └──────┬──────┘
                           │
           ┌───────────────┼───────────────┐
           ▼               ▼               ▼
    ┌─────────────┐ ┌─────────────┐ ┌─────────────┐
    │10-system/*  │ │20-users/*   │ │30-network/* │
    │ (apt, pkg)  │ │ (useradd)   │ │ (ssh, sudo) │
    └─────────────┘ └──────┬──────┘ └──────┬──────┘
                           │               │
                    ┌──────┴──────┐        │
                    ▼             ▼        │
              ┌─────────┐   ┌─────────┐    │
              │lib/user │   │lib/user │◄───┘
              └────┬────┘   └────┬────┘
                   │             │
                   └──────┬──────┘
                          ▼
                    ┌─────────────┐
                    │lib/common   │
                    │lib/security │
                    └─────────────┘
```

---

## Scalability Considerations

| Concern | At 1 Server | At 10 Servers | At 100 Servers |
|---------|-------------|---------------|----------------|
| **Execution** | Run script directly on server | Use parallel SSH (pssh) | Use configuration management (Ansible) |
| **Configuration** | Hardcoded in scripts | Separate config file | Centralized config management |
| **Logging** | Local log files | Centralized syslog | Structured logging with ELK |
| **Modules** | All in one repo | Separate module repos | Package manager (apt/rpm) |
| **Updates** | Re-run script | Script with idempotency | GitOps workflow |

**Note:** This architecture is designed for the 1-10 server range. Beyond that, consider migrating to tools like Ansible, Chef, or Puppet.

---

## Implementation Guidelines

### File Permissions
- Scripts in `bin/` and module directories: `755` (executable)
- Libraries in `lib/`: `644` (sourced, not executed directly)
- Configuration in `config/`: `600` (may contain sensitive data)

### Error Handling Strategy
1. **Module Level:** Each script exits non-zero on failure
2. **Orchestrator Level:** Entry point stops on first failure (fail-fast)
3. **Cleanup:** Trap handlers ensure temp files removed
4. **Reporting:** Final summary shows which modules succeeded/failed

### Testing Approach
- Unit tests for lib/*.sh functions (using bats or similar)
- Integration tests in Docker containers
- Test matrix: Fresh Ubuntu 24.04, different SSH key types

---

## Sources

### High Confidence
- **Shell Script Best Practices** (sharats.me) - Established patterns for safe bash
- **Minimal Safe Bash Script Template** (betterdev.blog) - Error handling patterns
- **Command Line Interface Guidelines** (clig.dev) - CLI design principles
- **s6-overlay** (GitHub) - Init stage patterns and ordered execution

### Medium Confidence
- **Oh My Zsh** (GitHub) - Plugin/modular architecture patterns
- **NVM** (GitHub) - Installation script patterns and shell integration
- **Homebrew Install** (GitHub) - Multi-platform bash installer patterns

### Patterns Derived From
- Standard bash best practices (errexit, nounset, pipefail)
- UNIX philosophy (do one thing well, compose tools)
- Configuration management patterns (Ansible, Chef)
