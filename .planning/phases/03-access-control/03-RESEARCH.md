# Phase 3: Access Control - Research

**Researched:** 2026-03-10
**Domain:** Linux sudo/sudoers Configuration and Security
**Confidence:** HIGH

## Summary

Phase 3 implements passwordless sudo configuration for two admin users (bryan, amazeeio) using the `/etc/sudoers.d/` drop-in directory pattern. This is the most security-critical phase — a sudoers syntax error can completely lock out root access, requiring physical console recovery or rescue mode.

**Primary recommendation:** Use `/etc/sudoers.d/` drop-in files (one per user) rather than editing `/etc/sudoers` directly. Validate all syntax with `visudo -c` before installing files. Set strict permissions (0440) on all sudoers.d files. The NOPASSWD tag enables passwordless sudo for the specified users.

**Key security insight:** Ubuntu 24.04 uses sudo 1.9.15p5 with the sudoers policy plugin. The `visudo -c` command provides syntax validation without requiring interactive editing. Drop-in files in `/etc/sudoers.d/` are automatically included and evaluated in lexical order.

---

## Standard Stack

### Core
| Component | Version | Purpose | Why Standard |
|-----------|---------|---------|--------------|
| sudo | 1.9.15p5 | Privilege escalation | Ubuntu 24.04 default, industry standard |
| visudo | 1.9.15p5 | Safe sudoers editing | Locks file, validates syntax, prevents corruption |
| /etc/sudoers.d/ | N/A | Modular privilege config | Cleaner than editing main file, easier to audit |
| NOPASSWD tag | N/A | Passwordless execution | Required for automated/admin workflows |

### File Locations
| Path | Purpose | Permissions |
|------|---------|-------------|
| `/etc/sudoers` | Main sudoers file | 0440 (root:root) |
| `/etc/sudoers.d/` | Drop-in directory | 0755 (root:root) |
| `/etc/sudoers.d/<user>` | User-specific rules | 0440 (root:root) |

### Installation
```bash
# sudo is pre-installed on Ubuntu 24.04, but for completeness:
apt-get install -y sudo
```

---

## Architecture Patterns

### Recommended Structure
```
etc/sudoers.d/
├── README           # Directory marker (ignored by sudo)
├── bryan            # bryan user rules (0440)
└── amazeeio         # amazeeio user rules (0440)
```

### Pattern 1: Single User Per File
**What:** Create one file per user in `/etc/sudoers.d/`
**When to use:** When managing individual user privileges
**Why:** Easier to audit, remove, and track changes per user

```bash
# /etc/sudoers.d/bryan
bryan ALL=(ALL) NOPASSWD: ALL
```

**Breakdown:**
- `bryan` — the user this rule applies to
- `ALL` — applies on all hosts
- `(ALL)` — may run as any user (root, etc.)
- `NOPASSWD:` — no password required
- `ALL` — may run any command

### Pattern 2: Syntax Validation Before Installation
**What:** Use `visudo -c` to validate sudoers syntax before moving files into place
**When to use:** ALWAYS — this is non-negotiable for safety
**Why:** Prevents lockout from syntax errors

```bash
# Create temporary file with sudoers content
cat > /tmp/sudoers_validation << 'EOF'
bryan ALL=(ALL) NOPASSWD: ALL
EOF

# Validate syntax (exit 0 = valid, exit 1 = error)
visudo -c -f /tmp/sudoers_validation || die "Invalid sudoers syntax"

# Only install if validation passed
mv /tmp/sudoers_validation /etc/sudoers.d/bryan
chmod 440 /etc/sudoers.d/bryan
```

### Pattern 3: Idempotency with Check-Before-Create
**What:** Verify if configuration already exists and matches before writing
**When to use:** All sudoers.d modifications
**Why:** Prevents unnecessary writes, supports re-runs

```bash
# Check if file exists with correct content
desired_content='bryan ALL=(ALL) NOPASSWD: ALL'
if [[ -f /etc/sudoers.d/bryan ]] && \
   [[ "$(cat /etc/sudoers.d/bryan)" == "$desired_content" ]]; then
    log_info "sudoers config for bryan already correct, skipping"
    return 0
fi

# Otherwise, validate and install
```

### Pattern 4: Strict Permissions
**What:** Set mode 0440 on all sudoers.d files immediately after creation
**When to use:** ALWAYS — sudo will refuse to read files with loose permissions
**Why:** Security requirement; sudo ignores files with permissions > 0440

```bash
chmod 440 /etc/sudoers.d/bryan
chown root:root /etc/sudoers.d/bryan
```

---

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Sudoers syntax validation | Custom parser | `visudo -c` | Official tool, handles all edge cases, includes security checks |
| Sudoers file editing | echo/printf directly | `visudo -c` + atomic mv | Prevents partial writes, validates before install |
| Passwordless sudo detection | grep /etc/sudoers manually | `sudo -n whoami` | Test actual behavior, handles drop-in files correctly |
| Permission setting | Manual chmod calculations | `chmod 440` | Standard mode, explicit and clear |

**Key insight:** Sudoers syntax is complex (supports aliases, wildcards, digest verification, etc.). A custom parser would miss edge cases and security implications. Always use `visudo -c` for validation.

---

## Common Pitfalls

### Pitfall 1: Syntax Error Lockout
**What goes wrong:** Invalid sudoers syntax causes sudo to reject ALL sudo operations, including root recovery
**Why it happens:** Sudo parses entire configuration; one syntax error invalidates everything
**How to avoid:**
1. ALWAYS use `visudo -c` before installing
2. Test validation in a separate process/session before applying
3. Never edit /etc/sudoers directly — use drop-in files
4. Keep a root shell open when testing changes

**Warning signs:** `visudo -c` exits non-zero, error messages about "syntax error near line X"

### Pitfall 2: Incorrect File Permissions
**What goes wrong:** sudo ignores files in sudoers.d with permissions > 0440 or not owned by root
**Why it happens:** Sudo enforces strict security on configuration files
**How to avoid:**
```bash
chmod 440 /etc/sudoers.d/filename
chown root:root /etc/sudoers.d/filename
```

**Warning signs:** User still prompted for password despite NOPASSWD rule, `sudo -l` doesn't show expected entries

### Pitfall 3: Trailing Newline Issues
**What goes wrong:** Missing trailing newline in sudoers file can cause parsing issues on some systems
**Why it happens:** Some parsers expect newline-terminated files
**How to avoid:** Always ensure files end with newline
```bash
echo "bryan ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/bryan
# echo adds newline automatically
```

### Pitfall 4: User Doesn't Exist
**What goes wrong:** Sudoers rule references a user that doesn't exist
**Why it happens:** Race condition between user creation and sudoers setup
**How to avoid:**
1. Ensure user creation module runs before sudoers module (phase dependency)
2. Verify user exists before creating sudoers rule
```bash
id "$username" &>/dev/null || die "User $username does not exist"
```

### Pitfall 5: Conflicting Rules
**What goes wrong:** Multiple sudoers entries for same user with conflicting tags (PASSWD vs NOPASSWD)
**Why it happens:** Later entries override earlier ones; PASSWD can override NOPASSWD
**How to avoid:**
1. Use single file per user in sudoers.d
2. Check for existing rules before adding new ones
3. Remove conflicting entries when enabling NOPASSWD

---

## Code Examples

### Validating Sudoers Syntax
```bash
# Source: visudo(8) man page
# Validate a sudoers file before installation

validate_sudoers() {
    local file="$1"
    
    # -c: check-only mode
    # -q: quiet (no output on success)
    # Returns 0 on success, 1 on syntax error
    if visudo -c -q -f "$file" 2>/dev/null; then
        return 0
    else
        return 1
    fi
}

# Usage
if ! validate_sudoers /tmp/new_sudoers; then
    die "Sudoers validation failed"
fi
```

### Creating Sudoers Drop-in File
```bash
# Source: sudoers(5) man page + Ubuntu best practices
# Create a passwordless sudo rule for a user

create_sudoers_rule() {
    local username="$1"
    local sudoers_file="/etc/sudoers.d/$username"
    local rule="$username ALL=(ALL) NOPASSWD: ALL"
    
    # Check if already correct (idempotency)
    if [[ -f "$sudoers_file" ]] && [[ "$(cat "$sudoers_file")" == "$rule" ]]; then
        log_info "Sudoers rule for $username already exists"
        return 0
    fi
    
    # Validate syntax before installing
    local temp_file
    temp_file=$(mktemp)
    echo "$rule" > "$temp_file"
    
    if ! visudo -c -q -f "$temp_file" 2>/dev/null; then
        rm -f "$temp_file"
        die "Invalid sudoers syntax for $username"
    fi
    
    # Install with correct permissions
    mv "$temp_file" "$sudoers_file"
    chmod 440 "$sudoers_file"
    chown root:root "$sudoers_file"
    
    log_info "Created sudoers rule for $username"
}
```

### Testing Passwordless Sudo
```bash
# Source: sudo(8) man page
# Verify passwordless sudo works for a user

test_passwordless_sudo() {
    local username="$1"
    
    # -n: non-interactive (fails if password required)
    # whoami: should return "root" if sudo works
    if su - "$username" -c "sudo -n whoami" 2>/dev/null | grep -q "^root$"; then
        return 0
    else
        return 1
    fi
}
```

---

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| Edit /etc/sudoers directly | Use /etc/sudoers.d/ drop-ins | Modern Ubuntu (10.04+) | Cleaner, modular, easier to audit |
| `sudo ALL` without NOPASSWD | Explicit `NOPASSWD:` tag | Always required | Clear intent, passwordless for automation |
| Manual syntax checking | `visudo -c` validation | Sudo 1.8+ | Automated validation in scripts |
| Mode 0644 on sudoers files | Mode 0440 | Sudo security hardening | Sudo refuses loose permissions |

**Deprecated/outdated:**
- Editing /etc/sudoers directly (use drop-ins)
- `sudoers_mode=0640` (use 0440)
- Comment-based disabling (use file removal)

---

## Open Questions

1. **Recovery procedure if sudo is broken?**
   - What we know: Physical console or rescue mode required
   - What's unclear: Document recovery steps?
   - Recommendation: Add warning to docs, verify before Phase 3 execution

2. **Should we backup existing sudoers.d files?**
   - What we know: Current project has no backup strategy
   - What's unclear: Is backup needed for clean installs?
   - Recommendation: For fresh servers, backup not needed; for existing, document risk

3. **Integration with future SSH hardening?**
   - What we know: SSH hardening in v2 requirements (SSH-01..04)
   - What's unclear: Any interaction between sudo and SSH config?
   - Recommendation: No direct interaction, but both affect remote access

---

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | BATS (Bash Automated Testing System) |
| Config file | None — test files are self-contained |
| Quick run command | `bats tests/test_sudoers.bats` |
| Full suite command | `bats tests/` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| SUDO-01 | bryan has passwordless sudo | integration | `su - bryan -c "sudo -n whoami"` | ❌ Wave 0 |
| SUDO-02 | amazeeio has passwordless sudo | integration | `su - amazeeio -c "sudo -n whoami"` | ❌ Wave 0 |
| SUDO-03 | Syntax validated before install | unit | `visudo -c` check in script | ❌ Wave 0 |
| SUDO-04 | Files have mode 440 | integration | `stat -c %a /etc/sudoers.d/*` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `bats tests/test_sudoers.bats 2>/dev/null || echo "Tests not yet created"`
- **Per wave merge:** `bats tests/`
- **Phase gate:** All sudo tests pass before `/gsd-verify-work`

### Wave 0 Gaps
- [ ] `tests/test_sudoers.bats` — covers SUDO-01, SUDO-02, SUDO-04
- [ ] `tests/test_sudoers_validation.bats` — covers SUDO-03
- [ ] Library function tests — `lib/sudo.sh` if created

---

## Sources

### Primary (HIGH confidence)
- [Ubuntu Manpage: sudoers(5)](https://manpages.ubuntu.com/manpages/noble/en/man5/sudoers.5.html) — Syntax specification, NOPASSWD tag, file format
- [Ubuntu Manpage: visudo(8)](https://manpages.ubuntu.com/manpages/noble/en/man8/visudo.8.html) — Validation commands, file permissions, options
- [Ubuntu Manpage: sudo(8)](https://manpages.ubuntu.com/manpages/noble/en/man8/sudo.8.html) — Runtime behavior, testing commands

### Secondary (MEDIUM confidence)
- Project STATE.md — Established patterns (check-before-create, source guards)
- Project lib/common.sh — Logging and error handling patterns
- Project lib/user.sh — Idempotency patterns

### Tertiary (LOW confidence)
- General bash/sudo knowledge — Validated against man pages

---

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — Official Ubuntu man pages
- Architecture: HIGH — Established patterns in project
- Pitfalls: HIGH — Man page warnings + security best practices

**Research date:** 2026-03-10
**Valid until:** 2027-03-10 (sudo rarely changes syntax)

---

*Research complete. Ready for planning phase.*
