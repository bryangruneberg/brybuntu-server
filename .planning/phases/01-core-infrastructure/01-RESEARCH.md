# Phase 1: Core Infrastructure - Research

**Researched:** 2025-03-10
**Domain:** Bash-based Ubuntu 24.04 LTS Server Automation
**Confidence:** HIGH

## Summary

Phase 1 establishes the foundational execution framework for the Brybuntu server automation system. Based on extensive research of established bash automation tools (Homebrew, Oh My Zsh, s6-overlay, cloud-init), the recommended approach is a **pure bash architecture** using modern Bash 5.2+ with strict mode (`set -euo pipefail`), modular script organization with numbered directories, and shared utility libraries.

**Primary recommendation:** Build a layered architecture with `install.sh` as orchestrator, `lib/common.sh` for shared utilities, and numbered scripts (10-*.sh, 20-*.sh) for ordered execution. Use `set -euo pipefail` for fail-fast error handling, implement explicit error checking beyond `set -e`, and follow check-before-create patterns for idempotency.

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| CORE-01 | Modular script architecture with numbered execution (10-*.sh, 20-*.sh, etc.) | Established pattern from s6-overlay, cloud-init; enables visual ordering without complex dependency resolution |
| CORE-02 | Main orchestrator script that discovers and executes modules in order | Homebrew installer pattern; filesystem scan + sort + execute |
| CORE-03 | Shared library for common functions (logging, error handling, idempotency checks) | Google Shell Style Guide pattern; source-once guards prevent double-loading |
| CORE-04 | Idempotent operations (safe to re-run without errors) | Check-before-create pattern: `if ! id "$user" &>/dev/null; then create; fi` |
| SYS-01 | Run `apt update` before any package operations | Standard Ubuntu provisioning pattern; use `DEBIAN_FRONTEND=noninteractive` |
| SYS-02 | Install kitty-terminfo package | Package available in Ubuntu 24.04 universe repository |
| SYS-03 | Error handling with explicit checks (not relying solely on `set -e`) | BashFAQ/105 documents `set -e` exceptions; explicit checking required |

## Standard Stack

### Core
| Library/Tool | Version | Purpose | Why Standard |
|--------------|---------|---------|--------------|
| Bash | 5.2+ | Scripting language | Ubuntu 24.04 ships 5.2.21; modern features available |
| adduser | 3.137ubuntu1 | User creation | Ubuntu/Debian explicitly recommends over `useradd` |
| apt | 2.7.14 | Package management | Native Ubuntu package manager |
| sudo | 1.9.15p5 | Privilege escalation | Standard Ubuntu 24.04 version |
| ShellCheck | 0.9.0 | Static analysis | Industry standard; catches security/logic issues |

### Supporting
| Tool | Version | Purpose | When to Use |
|------|---------|---------|-------------|
| kitty-terminfo | 0.31.0-1 | Terminal info | Required for proper terminal support (SYS-02) |
| openssl | 3.0.13 | Password generation | Random password generation for users |
| systemctl | 255 | Service management | Native systemd interface |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| Bash | Python/Ansible | Python adds dependency; Ansible is overkill for single server |
| adduser | useradd | `useradd` is lower-level, requires more flags, less user-friendly |
| ShellCheck | bash -n | `bash -n` only checks syntax, not logic/security issues |

## Architecture Patterns

### Recommended Project Structure
```
project-root/
├── install.sh              # Main orchestrator script
├── lib/
│   ├── common.sh          # Logging, error handling, utilities
│   └── security.sh        # Password generation, validation
├── modules/
│   ├── 10-system/
│   │   └── 10-update.sh   # System update (SYS-01)
│   │   └── 20-packages.sh # Package installation (SYS-02)
│   ├── 20-users/
│   └── 30-network/
└── config/
    └── settings.sh        # Configuration variables
```

### Pattern 1: Script Ordering by Filename
**What:** Scripts and directories prefixed with numbers (10-, 20-, 30-) execute in lexicographic order
**When to use:** When you need explicit execution order without complex dependency management
**Example:**
```bash
# Source: s6-overlay and cloud-init patterns
discover_modules() {
    local modules_dir="$1"
    find "$modules_dir" -maxdepth 2 -name "[0-9][0-9]-*.sh" -type f | sort
}

# Execution
for script in $(discover_modules "./modules"); do
    echo "Executing: $script"
    bash "$script" || exit 1
done
```

### Pattern 2: Shared Library with Source Guard
**What:** Common functions in `lib/common.sh` with guard against double-sourcing
**When to use:** When multiple scripts need shared utilities
**Example:**
```bash
# Source: Google Shell Style Guide
# lib/common.sh
if [[ -n "${BRYBUNTU_COMMON:-}" ]]; then
    return 0
fi
readonly BRYBUNTU_COMMON=1

# Logging functions
log_info() { echo "[INFO] $*"; }
log_error() { echo "[ERROR] $*" >&2; }

# Error handling
die() {
    log_error "$*"
    exit 1
}
```

### Pattern 3: Idempotent Operations
**What:** Check state before modifying; skip if already correct
**When to use:** All operations must be safe to re-run
**Example:**
```bash
# Source: Bash best practices (BashFAQ)
install_package() {
    local pkg="$1"
    if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
        log_info "$pkg already installed, skipping"
        return 0
    fi
    apt-get install -y "$pkg" || die "Failed to install $pkg"
}
```

### Pattern 4: Strict Mode with Explicit Checks
**What:** Use `set -euo pipefail` but don't rely on it exclusively
**When to use:** All production bash scripts
**Example:**
```bash
# Source: BashFAQ/105 - set -e behavior
#!/bin/bash
set -euo pipefail

# DON'T rely solely on this:
# some_command  # set -e catches this, but...

# DO use explicit checking:
if ! some_command; then
    die "some_command failed"
fi

# Or with proper error handling:
some_command || {
    log_error "some_command failed with $?"
    return 1
}
```

### Pattern 5: Non-Interactive apt
**What:** Set environment to prevent interactive prompts during automated installs
**When to use:** All automated apt operations
**Example:**
```bash
# Source: Ubuntu Server automation best practices
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq || die "apt update failed"
apt-get install -y -qq kitty-terminfo || die "Failed to install kitty-terminfo"
```

### Anti-Patterns to Avoid
- **Relying solely on `set -e`:** Doesn't trigger in pipelines (without pipefail), `&&`/`||` lists, or `if` statements
- **Unquoted variable expansion:** Always quote: `"$var"` not `$var` — prevents word splitting
- **Using `useradd` directly:** Ubuntu recommends `adduser` wrapper for interactive-friendly defaults
- **Sourcing without guards:** Double-sourcing libraries causes function redefinition errors

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| User creation | Manual `useradd` flags | `adduser` | Higher-level, Debian/Ubuntu blessed, handles home directory, sets defaults |
| Password generation | Custom random function | `openssl rand -base64 24` | Cryptographically secure, battle-tested |
| Error logging | Echo to stdout | Structured logging functions | Consistent format, redirectable levels |
| Module discovery | Hardcoded list | `find` + `sort` | Automatic, maintainable, supports adding modules |
| Idempotency checks | Complex state files | Check actual system state | Always correct, no stale state issues |

**Key insight:** Ubuntu server automation has well-established patterns in cloud-init and Ansible. Don't invent new abstractions—use proven patterns from these tools.

## Common Pitfalls

### Pitfall 1: Non-Idempotent Scripts
**What goes wrong:** Running script twice creates duplicate entries or fails with "already exists" errors
**Why it happens:** No check-before-create pattern
**How to avoid:** Always check state first: `if ! id "$user" &>/dev/null; then adduser ...; fi`
**Warning signs:** Script fails on second run, config files grow with duplicates

### Pitfall 2: Missing Error Handling
**What goes wrong:** Script continues after failure, leaves system in broken state
**Why it happens:** Relying solely on `set -e` which has complex exception rules
**How to avoid:** Use `set -euo pipefail` PLUS explicit error checking: `command || die "failed"`
**Warning signs:** Script exits 0 but operations failed; partial setup states

### Pitfall 3: Word Splitting and Globbing
**What goes wrong:** Variables with spaces cause unexpected behavior or security issues
**Why it happens:** Unquoted expansion: `$var` instead of `"$var"`
**How to avoid:** Always quote variable expansions; use ShellCheck (catches SC2086)
**Warning signs:** Commands fail mysteriously with paths containing spaces

### Pitfall 4: Subshell Variable Scope
**What goes wrong:** Variables set in pipelines don't persist to parent shell
**Why it happens:** Each pipeline element runs in subshell
**How to avoid:** Use `shopt -s lastpipe` (bash 4.2+) or process substitution `< <(command)`
**Warning signs:** Variable appears empty after pipeline assignment

### Pitfall 5: Not Checking Root Privileges
**What goes wrong:** Script fails midway with permission errors
**Why it happens:** Assumes root without validating
**How to avoid:** Early check: `if [[ $EUID -ne 0 ]]; then die "Must run as root"; fi`
**Warning signs:** Permission denied errors deep in script execution

### Pitfall 6: Missing `DEBIAN_FRONTEND`
**What goes wrong:** apt hangs waiting for interactive input
**Why it happens:** No TTY, but apt tries to prompt
**How to avoid:** Always set `DEBIAN_FRONTEND=noninteractive` before apt commands
**Warning signs:** Script hangs indefinitely at apt step

## Code Examples

### Module Discovery and Execution
```bash
#!/bin/bash
# Source: install.sh pattern from research
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_DIR

# Source common library
source "${SCRIPT_DIR}/lib/common.sh"

discover_modules() {
    local modules_dir="$1"
    find "$modules_dir" -maxdepth 2 -name "[0-9][0-9]-*.sh" -type f 2>/dev/null | sort -V
}

main() {
    check_root
    validate_environment
    
    log_info "Discovering modules..."
    local modules
    modules=$(discover_modules "${SCRIPT_DIR}/modules")
    
    if [[ -z "$modules" ]]; then
        die "No modules found in ${SCRIPT_DIR}/modules"
    fi
    
    local count=0
    while IFS= read -r script; do
        log_info "Executing: $(basename "$script")"
        bash "$script" || die "Module failed: $script"
        ((count++)) || true
    done <<< "$modules"
    
    log_info "Completed: $count modules executed"
}

main "$@"
```

### Idempotent Package Installation
```bash
#!/bin/bash
# Source: modules/10-system/10-update.sh pattern
set -euo pipefail

source "$(dirname "$0")/../../lib/common.sh"

update_system() {
    log_info "Updating package lists..."
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq || die "apt update failed"
    log_info "System update complete"
}

install_packages() {
    local packages=("$@")
    export DEBIAN_FRONTEND=noninteractive
    
    for pkg in "${packages[@]}"; do
        if dpkg -l "$pkg" 2>/dev/null | grep -q "^ii"; then
            log_info "$pkg already installed"
            continue
        fi
        
        log_info "Installing $pkg..."
        apt-get install -y -qq "$pkg" || die "Failed to install $pkg"
    done
}

main() {
    update_system
    install_packages "kitty-terminfo"
}

main "$@"
```

### Common Library Template
```bash
#!/bin/bash
# Source: lib/common.sh pattern
# shellcheck shell=bash

# Prevent double-sourcing
if [[ -n "${BRYBUNTU_COMMON:-}" ]]; then
    return 0
fi
readonly BRYBUNTU_COMMON=1

# Colors for terminal output (disable if not TTY)
if [[ -t 1 ]]; then
    readonly RED='\033[0;31m'
    readonly GREEN='\033[0;32m'
    readonly YELLOW='\033[1;33m'
    readonly NC='\033[0m' # No Color
else
    readonly RED=''
    readonly GREEN=''
    readonly YELLOW=''
    readonly NC=''
fi

# Logging functions
log_info() {
    printf "${GREEN}[INFO]${NC} %s\n" "$*"
}

log_warn() {
    printf "${YELLOW}[WARN]${NC} %s\n" "$*" >&2
}

log_error() {
    printf "${RED}[ERROR]${NC} %s\n" "$*" >&2
}

# Fatal error - exits script
die() {
    log_error "$*"
    exit 1
}

# Check if running as root
check_root() {
    if [[ $EUID -ne 0 ]]; then
        die "This script must be run as root"
    fi
}

# Validate Ubuntu version
validate_ubuntu() {
    if [[ ! -f /etc/os-release ]]; then
        die "Cannot detect OS version"
    fi
    
    # shellcheck source=/dev/null
    source /etc/os-release
    
    if [[ "$ID" != "ubuntu" ]]; then
        die "This script requires Ubuntu (found: $ID)"
    fi
    
    # Version check for 24.04 LTS
    if [[ "$VERSION_ID" != "24.04" ]]; then
        log_warn "Tested on Ubuntu 24.04, running on $VERSION_ID"
    fi
}
```

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `set -e` only | `set -euo pipefail` + explicit checks | Bash 4.0+ | Fail-fast with better error context |
| RSA SSH keys | Ed25519 keys | 2020+ | Shorter, faster, more secure keys |
| `useradd` | `adduser` | Always (Ubuntu) | More user-friendly, handles defaults |
| Global sudoers | `sudoers.d/` files | Modern Ubuntu | Modular, easier to manage |
| Interactive apt | `DEBIAN_FRONTEND=noninteractive` | Automation best practice | Prevents hangs in scripts |

**Deprecated/outdated:**
- RSA for SSH keys: Still works but Ed25519 preferred for new deployments
- `sudoers` direct editing: Use `sudoers.d/` drop-in files instead

## Validation Architecture

**Note:** `nyquist_validation` is enabled in config. This section documents testing approach.

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Bash built-in + ShellCheck + Bats (optional) |
| Config file | None — see Wave 0 setup |
| Quick run command | `shellcheck lib/*.sh modules/**/*.sh` |
| Full suite command | `./test/run-all.sh` (to be created) |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| CORE-01 | Numbered scripts execute in order | unit | `shellcheck install.sh && bash -n install.sh` | ❌ Wave 0 |
| CORE-02 | Orchestrator discovers modules | unit | Test module discovery logic | ❌ Wave 0 |
| CORE-03 | Common library loads without error | unit | `bash -n lib/common.sh` | ❌ Wave 0 |
| CORE-04 | Scripts are idempotent | integration | Run twice, verify no errors | ❌ Wave 0 |
| SYS-01 | apt update runs | integration | Check for apt update call | ❌ Wave 0 |
| SYS-02 | kitty-terminfo installs | integration | `dpkg -l kitty-terminfo` | ❌ Wave 0 |
| SYS-03 | Error handling works | unit | Test error paths with mock failures | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `shellcheck <modified_files>`
- **Per wave merge:** `./test/run-all.sh` (local validation script)
- **Phase gate:** All scripts pass ShellCheck, idempotency verified manually

### Wave 0 Gaps
- [ ] `lib/common.sh` — shared utility functions
- [ ] `install.sh` — main orchestrator
- [ ] `modules/10-system/` — system update module
- [ ] ShellCheck installation check in setup
- [ ] Local test runner script

## Open Questions

1. **Module script permissions**
   - What we know: Scripts should be executable (`chmod +x`)
   - What's unclear: Whether to enforce via git or runtime check
   - Recommendation: Enforce in repository, check at runtime

2. **Error aggregation vs fail-fast**
   - What we know: Current design implies fail-fast (exit on first error)
   - What's unclear: Whether to collect all errors and report at end
   - Recommendation: Fail-fast for Phase 1; aggregation adds complexity

3. **Logging destination**
   - What we know: Console output is minimum
   - What's unclear: Whether to also log to file
   - Recommendation: Start with console only; file logging in v2

## Sources

### Primary (HIGH confidence)
- **Bash Reference Manual** — https://www.gnu.org/software/bash/manual/bash.html — Version 5.3, strict mode behavior
- **Google Shell Style Guide** — https://google.github.io/styleguide/shellguide.html — Industry best practices for bash
- **ShellCheck** — https://github.com/koalaman/shellcheck — Static analysis patterns and warnings
- **BashFAQ/105** — https://mywiki.wooledge.org/BashFAQ/105 — set -e behavior and pitfalls
- **Ubuntu Server Documentation** — https://ubuntu.com/server/docs — Package management, user creation
- **cloud-init Documentation** — https://cloudinit.readthedocs.io/ — Module system patterns

### Secondary (MEDIUM confidence)
- **s6-overlay** — https://github.com/just-containers/s6-overlay — Init stage patterns, ordered execution
- **Homebrew Install** — https://github.com/Homebrew/install — Multi-platform bash installer patterns
- **donnemartin/dev-setup** — https://github.com/donnemartin/dev-setup — Modular bash architecture

### Tertiary (LOW confidence)
- Community blog posts and Stack Overflow — Specific implementation examples

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — Verified with official Ubuntu docs, package repositories
- Architecture: HIGH — Patterns from established tools (s6-overlay, cloud-init, Homebrew)
- Pitfalls: HIGH — Documented extensively in BashFAQ, ShellCheck

**Research date:** 2025-03-10
**Valid until:** 2025-06-10 (Ubuntu 24.04 LTS is stable; bash patterns are mature)

---
*Research complete — ready for planning*
