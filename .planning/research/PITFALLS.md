# Domain Pitfalls: Bash Server Automation

**Domain:** Ubuntu 24.04.3 LTS Server Setup via Bash Automation
**Researched:** 2026-03-10
**Confidence:** HIGH

## Critical Pitfalls

### Pitfall 1: Non-Idempotent Scripts
**What goes wrong:** Scripts fail on second run because they assume fresh state. Creating a user that already exists fails. Appending to config files creates duplicates. Package installs may fail or behave inconsistently.

**Why it happens:** Bash scripts execute linearly without tracking state. Most bash utilities (`useradd`, `apt install`, redirections like `echo "config" >> file`) are not idempotent by default.

**Consequences:**
- Duplicate entries in `/etc/sudoers`, `sshd_config`, or other config files
- Script failures on re-runs requiring manual cleanup
- Configuration drift between servers
- Broken package states

**Prevention:**
```bash
# Check before creating
if ! id "$USERNAME" &>/dev/null; then
    useradd -m "$USERNAME"
fi

# Check before appending
if ! grep -q "^config-line" "$CONFIG_FILE"; then
    echo "config-line" >> "$CONFIG_FILE"
fi

# Use apt idempotently (it mostly is, but check first)
dpkg -l package-name &>/dev/null || apt-get install -y package-name
```

**Detection:**
- Script exits with "user already exists" errors
- Multiple identical lines in config files
- `grep -c` showing duplicate entries

**Phase to address:** Phase 1 (Core Infrastructure) - All user creation and config modifications must be idempotent from the start.

---

### Pitfall 2: Missing Error Handling
**What goes wrong:** Commands fail silently, script continues, system ends up in broken state. `cd` fails but `rm -rf *` still runs in wrong directory.

**Why it happens:** Bash defaults to continuing on errors. `set -e` is unreliable (see BashFAQ/105) - it has confusing exception rules for subshells, conditionals, and pipelines.

**Consequences:**
- Partially configured systems
- Wrong files deleted or modified
- Silent failures masking root causes
- Security misconfigurations (e.g., sudoers partially written)

**Prevention:**
```bash
# Explicit error checking after critical commands
cd /some/path || { echo "Failed to cd"; exit 1; }

# For pipelines, check each component
cmd1 || exit 1
cmd2 || exit 1

# Use ERR trap for centralized error handling
cleanup() {
    local exit_code=$?
    # cleanup logic
    exit $exit_code
}
trap cleanup ERR
```

**Detection:**
- Commands followed by `|| true` to suppress errors
- No exit code checking after `cd`, `cp`, `mv`
- Scripts that "succeed" but don't actually work

**Phase to address:** Phase 1 (Core Infrastructure) - Error handling must be built into the execution framework from day one.

---

### Pitfall 3: Word Splitting and Globbing
**What goes wrong:** Unquoted variables cause word splitting on whitespace and unintended glob expansion. A filename with spaces breaks the script.

**Why it happens:** Bash performs word splitting on unquoted variables using `$IFS` (default: space, tab, newline). Unquoted `*` or `?` characters trigger glob expansion.

**Consequences:**
- Files with spaces in names processed as multiple files
- Security vulnerabilities (filenames starting with `-` interpreted as flags)
- Data loss or corruption
- Script failures on unexpected filenames

**Prevention:**
```bash
# ALWAYS quote variable expansions
cp "$source" "$dest"

# Handle filenames with dashes
rm -- "$file"  # or rm "./$file"

# Use arrays for lists of files
files=("/path/to/file 1" "/path/to/file 2")
for f in "${files[@]}"; do
    process "$f"
done
```

**Detection:**
- ShellCheck warnings: SC2086 (double quote to prevent globbing and word splitting)
- `for f in $var` instead of `for f in "$var"`
- Commands like `cp $src $dst` without quotes

**Phase to address:** Phase 1 (Core Infrastructure) - Code style enforcement should catch these immediately.

---

### Pitfall 4: Subshell Variable Scope
**What goes wrong:** Variables set inside pipelines, command substitutions, or subshells don't persist to parent shell.

**Why it happens:** Each command in a pipeline runs in a separate subshell. Changes to variables in subshells don't affect parent scope.

**Consequences:**
- Counters or state variables don't accumulate correctly
- Data from loops lost after pipeline completes
- Scripts appear to work but produce no lasting changes

**Prevention:**
```bash
# WRONG - count won't persist
grep pattern file | while read -r line; do
    ((count++))
done
echo "$count"  # Always 0

# RIGHT - use process substitution with lastpipe (bash 4.2+)
shopt -s lastpipe
grep pattern file | while read -r line; do
    ((count++))
done

# RIGHT - use file descriptor redirection
while read -r line; do
    ((count++))
done < <(grep pattern file)

# RIGHT - for simple cases, avoid pipeline
while read -r line; do
    [[ $line == *pattern* ]] && ((count++))
done < file
```

**Detection:**
- Variables assigned inside `|` pipelines
- Using `$(...)` to set variables
- ShellCheck warning SC2030/SC2031 about variable modification

**Phase to address:** Phase 1 (Core Infrastructure) - Any data collection across commands needs this addressed.

---

### Pitfall 5: set -e (errexit) Misunderstanding
**What goes wrong:** Developers assume `set -e` makes scripts "strict" and fail on all errors. It doesn't.

**Why it happens:** `set -e` has complex exception rules documented in BashFAQ/105. It doesn't trigger on:
- Commands in `if`/`while`/`until` tests
- Commands in `&&`/`||` lists (except last)
- Commands in pipelines (except last, without pipefail)
- Commands in functions called as conditions
- Subshell behavior varies by bash version and POSIX mode

**Consequences:**
- False sense of security
- Silent failures in "protected" scripts
- Unpredictable behavior across bash versions

**Prevention:**
```bash
# Don't rely on set -e alone
# Explicit checking is more reliable

# BAD - might not exit
set -e
some_command  # This might not fail the script!

# GOOD - explicit error handling
some_command || { echo "Command failed"; exit 1; }

# For functions, propagate errors properly
my_func() {
    command1 || return 1
    command2 || return 1
}
my_func || exit 1
```

**Detection:**
- Scripts that use `set -e` as the only error handling
- No explicit error checking on critical commands
- Assumptions that "strict mode" catches all errors

**Phase to address:** Phase 1 (Core Infrastructure) - Define explicit error handling strategy instead of relying on `set -e`.

---

### Pitfall 6: Improper Sudoers Editing
**What goes wrong:** Syntax errors in `/etc/sudoers` or files in `/etc/sudoers.d/` can lock out all root access, requiring physical console recovery.

**Why it happens:** Sudo validates its configuration. One syntax error can make sudo refuse all operations. Direct file editing risks broken syntax.

**Consequences:**
- Complete lockout from root privileges
- Need for physical console access or recovery mode
- Production server downtime

**Prevention:**
```bash
# NEVER edit /etc/sudoers directly
# Use visudo for the main file

# For drop-in files, validate before installing
SUDOERS_FILE="/etc/sudoers.d/50-myconfig"
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" > /tmp/sudoers_check

# Validate syntax
if visudo -c -f /tmp/sudoers_check; then
    mv /tmp/sudoers_check "$SUDOERS_FILE"
    chmod 0440 "$SUDOERS_FILE"
else
    echo "Sudoers syntax error!"
    exit 1
fi
```

**Detection:**
- Direct `echo` or `cat` to `/etc/sudoers`
- No syntax validation before installation
- Missing `chmod 0440` on sudoers.d files

**Phase to address:** Phase 1 (Core Infrastructure) - User creation and sudo configuration are critical security steps.

---

### Pitfall 7: SSH Lockout During Configuration
**What goes wrong:** Script modifies SSH config, restarts SSH, and the new configuration prevents the current session from reconnecting. Or worse, script loses SSH connection mid-run.

**Why it happens:** SSH configuration changes can accidentally disable root login, password auth, or the specific auth method the script relies on.

**Consequences:**
- Complete loss of remote access
- Script aborts mid-execution, leaving system in inconsistent state
- Need for physical console access

**Prevention:**
```bash
# Always test SSH config before reloading
sshd -t || { echo "SSH config invalid"; exit 1; }

# Keep current session alive, reload for new connections
# Don't restart sshd - reload instead
systemctl reload sshd  # or service ssh reload

# Verify new connection works before closing old one
ssh -o ConnectTimeout=5 newuser@localhost echo "SSH OK" || {
    echo "SSH connection test failed!"
    # Consider rollback
}

# Use trap to ensure cleanup on disconnect
trap 'echo "Connection lost, cleaning up..."' HUP
```

**Detection:**
- `systemctl restart sshd` without config test
- No validation of new SSH settings
- No fallback or rollback mechanism

**Phase to address:** Phase 1 (Core Infrastructure) - SSH configuration is one of the first tasks; lockout is catastrophic.

---

### Pitfall 8: Not Checking Root Privileges
**What goes wrong:** Script assumes it's running as root but isn't, or runs as root when it shouldn't. Commands fail with permission errors or security is compromised.

**Why it happens:** Scripts may be copied to new environments, executed via sudo in some cases but not others, or run directly as root when sudo was intended.

**Consequences:**
- Permission denied errors mid-script
- Partial system configuration
- Security issues from running unnecessary operations as root
- Silent failures on permission-dependent operations

**Prevention:**
```bash
# Check for root at start if required
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

# Or for non-root requirement
if [[ $EUID -eq 0 ]]; then
   echo "Do not run this script as root"
   exit 1
fi

# Check specific capabilities when possible
if ! capsh --print | grep -q "cap_sys_admin"; then
    echo "Missing required capabilities"
    exit 1
fi
```

**Detection:**
- Scripts that use `sudo` internally instead of requiring root upfront
- No UID check at script start
- Mixed root/non-root operations without clear boundaries

**Phase to address:** Phase 1 (Core Infrastructure) - The bootstrap script must validate its execution context.

---

## Moderate Pitfalls

### Pitfall 9: Poor Random Password Generation
**What goes wrong:** Using weak random sources (`$RANDOM`, `date`, simple patterns) creates predictable passwords that compromise security.

**Why it happens:** Bash's `$RANDOM` is not cryptographically secure. Other naive approaches have limited entropy.

**Consequences:**
- Easily guessable passwords
- Security audit failures
- Compromised accounts

**Prevention:**
```bash
# GOOD - use /dev/urandom
password=$(tr -dc 'a-zA-Z0-9!@#$%^&*' < /dev/urandom | head -c 16)

# GOOD - OpenSSL if available
password=$(openssl rand -base64 16)

# AVOID
password="$RANDOM$RANDOM"  # Weak!
password=$(date +%s)        # Predictable!
```

**Phase to address:** Phase 1 (Core Infrastructure) - Password generation is part of user setup.

---

### Pitfall 10: Missing Dependency Checks
**What goes wrong:** Script assumes tools are installed (`useradd`, `apt-get`, `systemctl`) but runs on minimal system without them.

**Why it happens:** Ubuntu minimal or container images may lack standard tools. Script ported to different distro.

**Consequences:**
- "Command not found" errors
- Incomplete execution
- Wrong assumptions about environment

**Prevention:**
```bash
# Check for required commands
deps=("useradd" "passwd" "apt-get" "systemctl")
for dep in "${deps[@]}"; do
    if ! command -v "$dep" &> /dev/null; then
        echo "Required command not found: $dep"
        exit 1
    fi
done

# Check Ubuntu version
if ! grep -q "Ubuntu 24.04" /etc/os-release; then
    echo "This script is designed for Ubuntu 24.04"
    # Decide: exit or warn
fi
```

**Phase to address:** Phase 1 (Core Infrastructure) - Validate environment before proceeding.

---

### Pitfall 11: Incorrect Exit Code Handling
**What goes wrong:** Script exits with success (0) when it actually failed, or fails with generic exit code hiding the real issue.

**Why it happens:** Commands that fail are followed by `echo` which succeeds, or script uses `exit` without capturing/propagating the actual error code.

**Consequences:**
- CI/CD thinks deployment succeeded
- Orchestration tools don't retry
- Harder troubleshooting without specific error codes

**Prevention:**
```bash
# Capture and propagate exit codes
if ! some_command; then
    exit_code=$?
    echo "some_command failed with code $exit_code"
    exit $exit_code
fi

# Use trap to ensure proper exit codes
trap 'exit $?' ERR
```

**Phase to address:** Phase 1 (Core Infrastructure) - Part of error handling framework.

---

### Pitfall 12: Uninitialized Variables
**What goes wrong:** Variables used before being set expand to empty strings, causing unexpected behavior or errors with `set -u`.

**Why it happens:** Typo in variable name, variable set in conditional path not taken, sourced file missing.

**Consequences:**
- Commands operating on wrong/default paths
- Silent data loss
- Script crashes with `set -u`

**Prevention:**
```bash
# Initialize with defaults
: "${USERNAME:=defaultuser}"
: "${HOMEDIR:=/home/$USERNAME}"

# Or explicit initialization
USERNAME="${USERNAME:-}"
if [[ -z "$USERNAME" ]]; then
    echo "USERNAME must be set"
    exit 1
fi

# Use nounset in development (carefully)
# set -u  # Uncomment after fixing all uninitialized vars
```

**Phase to address:** Phase 1 (Core Infrastructure) - Configuration management should validate inputs.

---

## Minor Pitfalls

### Pitfall 13: Locale/LC_ALL Issues
**What goes wrong:** Scripts parsing command output break when system locale changes sort order, date formats, or decimal separators.

**Prevention:**
```bash
# Force C locale for consistent output
LC_ALL=C sort
LC_ALL=C date
```

**Phase to address:** Phase 1 (Core Infrastructure) - Any output parsing needs locale consideration.

---

### Pitfall 14: Race Conditions in Parallel Execution
**What goes wrong:** When scripts run in parallel or on fast machines, assumptions about execution order cause intermittent failures.

**Prevention:**
```bash
# Wait for background jobs
cmd1 &
cmd2 &
wait  # Wait for both to complete

# Check job status
if [[ $(jobs -r | wc -l) -gt 0 ]]; then
    echo "Background jobs still running"
fi
```

**Phase to address:** Phase 2+ (Future parallel execution features)

---

### Pitfall 15: Hardcoded Paths
**What goes wrong:** Scripts use hardcoded paths that differ between distributions or versions (`/bin/bash` vs `/usr/bin/bash`).

**Prevention:**
```bash
#!/usr/bin/env bash  # Portable shebang

# Use command -v to find paths
BASH_PATH=$(command -v bash)
```

**Phase to address:** Phase 1 (Core Infrastructure) - Use portable patterns from the start.

---

## Phase-Specific Warnings

| Phase | Topic | Likely Pitfall | Mitigation |
|-------|-------|----------------|------------|
| Phase 1 | User creation | User already exists, UID conflicts | Check `id` before creating, validate UID range |
| Phase 1 | Sudo configuration | Syntax errors lock out root | Use `visudo -c` to validate, atomic file operations |
| Phase 1 | SSH setup | Lockout during config changes | Test config with `sshd -t`, reload not restart |
| Phase 1 | Package installation | Non-interactive frontend issues | Set `DEBIAN_FRONTEND=noninteractive` |
| Phase 1 | Password generation | Weak random source | Use `/dev/urandom` or `openssl` |
| Phase 1 | File permissions | World-readable sensitive files | Explicit `chmod` after file creation |
| Phase 2+ | Service management | Race conditions on service start | Use `systemctl is-active` checks with timeouts |

---

## Recommended Safeguards

### For All Scripts
1. **Use ShellCheck** - Integrate into CI/CD and editor
2. **Explicit error checking** - Don't rely on `set -e`
3. **Quote all expansions** - `"$var"` not `$var`
4. **Idempotent operations** - Check before creating/modifying
5. **Validate inputs** - Check environment before proceeding

### For Server Automation
1. **Test on fresh VMs** - Not just re-running on same system
2. **Rollback capability** - Keep backups of modified configs
3. **Validate before applying** - Test SSH/sudoers syntax
4. **Connection resilience** - Handle SSH timeouts gracefully
5. **Logging** - Comprehensive output for troubleshooting

---

## Sources

- BashFAQ/105 - https://mywiki.wooledge.org/BashFAQ/105 (set -e behavior)
- BashPitfalls - https://mywiki.wooledge.org/BashPitfalls (comprehensive pitfalls list)
- ShellCheck - https://www.shellcheck.net/ (static analysis tool)
- GNU Bash Manual - https://www.gnu.org/software/bash/manual/ (official documentation)
- Linuxize useradd guide - https://linuxize.com/post/how-to-create-users-in-linux-using-the-useradd-command/
- TLDP Bash Guide - https://tldp.org/LDP/Bash-Beginners-Guide/html/ (debugging techniques)
