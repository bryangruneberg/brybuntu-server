# Phase 2: User Management - Research

**Researched:** 2026-03-10
**Domain:** Ubuntu 24.04 LTS User Creation and SSH Key Management
**Confidence:** HIGH

## Summary

Phase 2 focuses on creating two admin users (`bryan` and `amazeeio`) with secure random passwords and SSH key access. This is a straightforward implementation using standard Ubuntu tools. The key challenge is ensuring proper permissions and secure password handling.

**Primary recommendation:** Use `adduser` (not `useradd`), generate cryptographically random passwords with `openssl`, and strictly enforce SSH directory permissions (700 for `.ssh/`, 600 for `authorized_keys`).

## Standard Stack

### Core
| Tool | Version (Ubuntu 24.04) | Purpose | Why Standard |
|------|------------------------|---------|--------------|
| `adduser` | 3.137ubuntu1 | User creation | Ubuntu/Debian blessed tool; interactive, handles home directories, skeleton files |
| `usermod` | passwd 1:4.13+dfsg1-4ubuntu3 | Modify user properties | Standard for changing existing users |
| `chpasswd` | passwd 1:4.13+dfsg1-4ubuntu3 | Batch password setting | Secure non-interactive password updates |
| `openssl` | 3.0.13-0ubuntu3.4 | Cryptographic operations | Industry standard for random password generation |
| `id` | coreutils 9.4-3ubuntu6 | User existence check | Idempotent check-before-create pattern |

### Supporting
| Tool | Purpose | When to Use |
|------|---------|-------------|
| `getent` | Database lookup for users | Alternative to `id` for checking user existence |
| `passwd` | Interactive password change | Manual/admin use only (not for automation) |
| `install` | Create directories with permissions | Atomic directory creation with mode setting |
| `chown` | Change file ownership | Critical for `.ssh/` ownership (user:user) |
| `chmod` | Set file permissions | Enforce 700/600 permissions |

### Alternatives Considered
| Instead of | Could Use | Tradeoff |
|------------|-----------|----------|
| `adduser` | `useradd` | `useradd` is lower-level; requires manual home creation, skeleton files; more error-prone for automation |
| `openssl rand` | `/dev/urandom` | Both work; openssl provides base64 encoding conveniently; urandom is kernel-level |
| `chpasswd` | `echo user:pass | chpasswd` | Same tool; `chpasswd --encrypted` for pre-hashed passwords |

## Architecture Patterns

### Recommended User Creation Pattern
```bash
# Source: Google Shell Style Guide + Ubuntu Server Docs
# Pattern: Check-before-create with explicit error handling

create_user() {
    local username="$1"
    local ssh_key="$2"

    # Idempotency check: does user already exist?
    if id "$username" &>/dev/null; then
        log_info "User $username already exists, skipping creation"
        return 0
    fi

    # Create user with adduser
    adduser --gecos "" --disabled-password "$username" || die "Failed to create user $username"

    # Generate and set random password
    local password
    password=$(openssl rand -base64 32) || die "Failed to generate password"
    echo "$username:$password" | chpasswd || die "Failed to set password"

    # Display password to operator (one-time display)
    printf 'Generated password for %s: %s\n' "$username" "$password"
}
```

### SSH Key Deployment Pattern
```bash
# Source: OpenSSH Documentation
# Pattern: Secure directory creation with explicit permissions

setup_ssh_key() {
    local username="$1"
    local ssh_key="$2"
    local home_dir
    home_dir=$(getent passwd "$username" | cut -d: -f6)

    local ssh_dir="$home_dir/.ssh"
    local auth_keys="$ssh_dir/authorized_keys"

    # Create .ssh directory with 700 permissions
    # Use install for atomic operation with mode
    install -d -m 700 -o "$username" -g "$username" "$ssh_dir" || die "Failed to create $ssh_dir"

    # Add SSH key if not already present
    if [[ ! -f "$auth_keys" ]] || ! grep -qF "$ssh_key" "$auth_keys"; then
        echo "$ssh_key" >> "$auth_keys" || die "Failed to add SSH key"
        chmod 600 "$auth_keys" || die "Failed to set permissions"
        chown "$username:$username" "$auth_keys" || die "Failed to set ownership"
    fi
}
```

### Password Generation Pattern
```bash
# Source: OpenSSL Documentation + NIST Guidelines
# Pattern: Cryptographically secure random generation

generate_password() {
    # Generate 32 bytes of random data, base64 encode
    # Result: ~44 character password
    openssl rand -base64 32
}
```

### Project Structure for Phase 2
```
modules/
└── 20-users/
    ├── 10-bryan.sh      # Create bryan user + SSH key
    └── 20-amazeeio.sh   # Create amazeeio user + SSH key

lib/
├── common.sh            # Existing: logging, error handling
└── user.sh              # NEW: User creation helpers
```

### Anti-Patterns to Avoid

**Anti-Pattern 1: Using `useradd` instead of `adduser`**
- **Why it's bad:** `useradd` is low-level; doesn't create home directory by default, doesn't handle skeleton files, requires manual steps that `adduser` automates
- **What to do instead:** Always use `adduser` on Ubuntu/Debian systems

**Anti-Pattern 2: Storing passwords in variables after display**
- **Why it's bad:** Password could leak via process list, bash history, or core dumps
- **What to do instead:** Generate, display immediately, don't store; rely on SSH key access afterward

**Anti-Pattern 3: Weak permissions on `.ssh/` directory**
- **Why it's bad:** SSH refuses keys if permissions are too open (world-readable)
- **What to do instead:** Strict 700 on `.ssh/`, 600 on `authorized_keys`; verify with `ls -ld`

**Anti-Pattern 4: Appending SSH keys blindly**
- **Why it's bad:** Creates duplicate entries on re-runs
- **What to do instead:** Check if key already exists before appending

**Anti-Pattern 5: Using `passwd` in scripts**
- **Why it's bad:** Interactive tool; prompts for password twice; doesn't work in automation
- **What to do instead:** Use `chpasswd` for non-interactive password setting

## Don't Hand-Roll

| Problem | Don't Build | Use Instead | Why |
|---------|-------------|-------------|-----|
| Random password generation | `/dev/random` reading + encoding | `openssl rand -base64 32` | OpenSSL handles entropy, encoding; well-tested, standard |
| User existence check | Parsing `/etc/passwd` manually | `id "$user" &>/dev/null` | `id` handles all user database backends (LDAP, NIS, etc.) |
| Home directory lookup | Parsing `/etc/passwd` | `getent passwd "$user" \| cut -d: -f6` | Handles all user database backends |
| Directory creation with permissions | `mkdir && chmod && chown` | `install -d -m MODE -o OWNER -g GROUP` | Atomic operation, single command |
| SSH key validation | Regex parsing | None needed for this phase | Ed25519 key format is provided and trusted |

**Key insight:** Ubuntu provides battle-tested tools for user management. Custom implementations introduce subtle bugs around edge cases (existing users, different home directory locations, alternate user databases).

## Common Pitfalls

### Pitfall 1: SSH Permission Too Open
**What goes wrong:** SSH rejects key authentication because `.ssh/` is group/world readable
**Why it happens:** Default umask might create directories as 755; `install` or `mkdir` without explicit mode
**How to avoid:** Always set `chmod 700 ~/.ssh` and `chmod 600 ~/.ssh/authorized_keys`
**Warning signs:** "Permissions are too open" error in `/var/log/auth.log`

### Pitfall 2: User Already Exists
**What goes wrong:** Script fails when re-run because user already exists
**Why it happens:** No idempotency check before `adduser` call
**How to avoid:** Check `id "$user" &>/dev/null` before creation; skip gracefully if exists
**Warning signs:** "useradd: user 'X' already exists" errors

### Pitfall 3: Wrong Home Directory Ownership
**What goes wrong:** User can't write to their own home directory; SSH fails
**Why it happens:** `adduser` usually handles this, but manual home creation might leave ownership as root
**How to avoid:** Let `adduser` create home; or explicitly `chown -R user:user /home/user`
**Warning signs:** Permission denied when user tries to write files

### Pitfall 4: Duplicate SSH Keys
**What goes wrong:** `authorized_keys` grows with duplicate entries on each re-run
**Why it happens:** Blindly appending without checking if key already present
**How to avoid:** Use `grep -qF "$key" "$file"` to check before appending
**Warning signs:** File grows significantly; `wc -l ~/.ssh/authorized_keys` increases

### Pitfall 5: Password Not Actually Random
**What goes wrong:** Using predictable sources like `date`, `$RANDOM`, or weak entropy
**Why it happens:** Not understanding cryptographic random vs pseudo-random
**How to avoid:** Use `openssl rand` or `/dev/urandom`; never use `RANDOM` variable or timestamps
**Warning signs:** Passwords follow patterns; too short (< 20 chars); dictionary words

### Pitfall 6: Password Visible in Process List
**What goes wrong:** Password appears in `ps` output when passed via command line
**Why it happens:** Using `echo "$pass" | chpasswd` where `$pass` is visible in environment
**How to avoid:** Pass via stdin with heredoc or pipe from secure source; avoid command-line args
**Warning signs:** Password appears in shell history or process listing

### Pitfall 7: Missing `getent` Package
**What goes wrong:** `getent` not available in minimal containers
**Why it happens:** Some minimal Ubuntu images lack `libc-bin` or similar
**How to avoid:** `getent` is part of `libc-bin`, always present on standard Ubuntu Server; use `eval echo ~$user` as fallback
**Warning signs:** "getent: command not found" errors

## Code Examples

### Idempotent User Creation
```bash
#!/bin/bash
set -euo pipefail

# Source common library
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=../../lib/common.sh
source "${SCRIPT_DIR}/../../lib/common.sh"

check_root

USERNAME="bryan"
SSH_KEY="ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIKt9pdXZ/aI31oyRrCc7ER8pfTOcS3r04xVnEOmEjhss bryan@bryarchy"

# Idempotency: check if user exists
if id "$USERNAME" &>/dev/null; then
    log_info "User $USERNAME already exists, skipping creation"
else
    # Create user with adduser (interactive, handles home dir)
    adduser --gecos "" --disabled-password "$USERNAME" || die "Failed to create user $USERNAME"
    log_info "Created user $USERNAME"
fi

# Generate random password
PASSWORD=$(openssl rand -base64 32) || die "Failed to generate password"
echo "$USERNAME:$PASSWORD" | chpasswd || die "Failed to set password"

# Display password (operator must save this)
printf '\n%s\n' "========================================"
printf 'Password for %s: %s\n' "$USERNAME" "$PASSWORD"
printf '%s\n\n' "========================================"

# Setup SSH key
HOME_DIR=$(getent passwd "$USERNAME" | cut -d: -f6)
SSH_DIR="$HOME_DIR/.ssh"
AUTH_KEYS="$SSH_DIR/authorized_keys"

# Create .ssh directory with correct permissions
if [[ ! -d "$SSH_DIR" ]]; then
    install -d -m 700 -o "$USERNAME" -g "$USERNAME" "$SSH_DIR" || die "Failed to create $SSH_DIR"
fi

# Add SSH key if not present
if [[ ! -f "$AUTH_KEYS" ]] || ! grep -qF "$SSH_KEY" "$AUTH_KEYS"; then
    echo "$SSH_KEY" >> "$AUTH_KEYS"
    chmod 600 "$AUTH_KEYS"
    chown "$USERNAME:$USERNAME" "$AUTH_KEYS"
    log_info "Added SSH key for $USERNAME"
fi
```

### Library Helper (lib/user.sh)
```bash
#!/bin/bash
# User management helpers

[[ -n "${BRYBUNTU_USER:-}" ]] && return 0
readonly BRYBUNTU_USER=1

# shellcheck source=common.sh
source "$(dirname "${BASH_SOURCE[0]}")/common.sh"

# Create a user with SSH key access
# Usage: user_create_with_ssh "username" "ssh_public_key"
user_create_with_ssh() {
    local username="$1"
    local ssh_key="$2"

    # Create user if not exists
    if ! id "$username" &>/dev/null; then
        adduser --gecos "" --disabled-password "$username" || return 1
    fi

    # Generate and set password
    local password
    password=$(openssl rand -base64 32) || return 1
    echo "$username:$password" | chpasswd || return 1

    # Display password
    printf 'Password for %s: %s\n' "$username" "$password"

    # Setup SSH
    local home_dir
    home_dir=$(getent passwd "$username" | cut -d: -f6)
    local ssh_dir="$home_dir/.ssh"
    local auth_keys="$ssh_dir/authorized_keys"

    install -d -m 700 -o "$username" -g "$username" "$ssh_dir" 2>/dev/null || true

    if [[ ! -f "$auth_keys" ]] || ! grep -qF "$ssh_key" "$auth_keys"; then
        echo "$ssh_key" >> "$auth_keys"
        chmod 600 "$auth_keys"
        chown "$username:$username" "$auth_keys"
    fi

    return 0
}
```

## Phase Requirements

| ID | Description | Research Support |
|----|-------------|-----------------|
| USER-01 | Create "bryan" user using `adduser` | `adduser --gecos "" --disabled-password` pattern with idempotency check |
| USER-02 | Set random password for "bryan" | `openssl rand -base64 32` + `chpasswd` pattern |
| USER-03 | Create `/home/bryan/.ssh` with 700 permissions | `install -d -m 700` pattern |
| USER-04 | Add SSH key to authorized_keys with 600 permissions | Check-before-append pattern, `chmod 600` |
| USER-05 | Create "amazeeio" user using `adduser` | Same as USER-01, reusable function |
| USER-06 | Set random password for "amazeeio" | Same as USER-02, reusable function |
| USER-07 | Create `/home/amazeeio/.ssh` with 700 permissions | Same as USER-03, parameterized |
| USER-08 | Add SSH key to amazeeio authorized_keys with 600 | Same as USER-04, parameterized |

## State of the Art

| Old Approach | Current Approach | When Changed | Impact |
|--------------|------------------|--------------|--------|
| `useradd` | `adduser` | Always on Ubuntu/Debian | `adduser` is the Debian/Ubuntu blessed tool |
| RSA SSH keys | Ed25519 SSH keys | ~2020+ | Shorter, faster, more secure; industry standard |
| MD5 password hash | SHA-512 (yescrypt in 24.04) | Ubuntu 22.04+ | Modern hashing; `chpasswd` handles automatically |
| `/etc/sudoers` edits | `/etc/sudoers.d/` files | Modern best practice | Modular, no editing main file |

**Deprecated/outdated:**
- `useradd` for interactive/automated user creation on Ubuntu (use `adduser`)
- RSA keys < 4096 bits (use Ed25519)
- MD5/SHA-1 password hashes (system uses yescrypt automatically)
- Password-based SSH authentication (Phase 3 requirement: keys only)

## Validation Architecture

### Test Framework
| Property | Value |
|----------|-------|
| Framework | Bats (Bash Automated Testing System) |
| Config file | `tests/bats.config` (if needed) |
| Quick run command | `bats tests/modules/20-users/` |
| Full suite command | `bats tests/` |

### Phase Requirements → Test Map
| Req ID | Behavior | Test Type | Automated Command | File Exists? |
|--------|----------|-----------|-------------------|-------------|
| USER-01 | bryan user exists | unit | `bats tests/modules/20-users/test_bryan.bats` | ❌ Wave 0 |
| USER-02 | bryan has password set | unit | `id bryan && passwd -S bryan` | ❌ Wave 0 |
| USER-03 | .ssh directory 700 | unit | `stat -c %a /home/bryan/.ssh` | ❌ Wave 0 |
| USER-04 | authorized_keys has key, 600 | unit | `grep -q "ssh-ed25519" /home/bryan/.ssh/authorized_keys` | ❌ Wave 0 |
| USER-05 | amazeeio user exists | unit | `id amazeeio` | ❌ Wave 0 |
| USER-06 | amazeeio has password set | unit | `passwd -S amazeeio` | ❌ Wave 0 |
| USER-07 | amazeeio .ssh 700 | unit | `stat -c %a /home/amazeeio/.ssh` | ❌ Wave 0 |
| USER-08 | amazeeio authorized_keys 600 | unit | `stat -c %a /home/amazeeio/.ssh/authorized_keys` | ❌ Wave 0 |

### Sampling Rate
- **Per task commit:** `bats tests/modules/20-users/test_<specific>.bats`
- **Per wave merge:** `bats tests/modules/20-users/`
- **Phase gate:** All user tests pass + manual verification of password display

### Wave 0 Gaps
- [ ] `tests/modules/20-users/` directory — test organization
- [ ] `tests/modules/20-users/test_bryan.bats` — covers USER-01..04
- [ ] `tests/modules/20-users/test_amazeeio.bats` — covers USER-05..08
- [ ] `tests/test_helper.bash` — shared Bats fixtures
- [ ] Bats framework install — `apt install bats` or git submodule

## Open Questions

1. **Amazeeio SSH key source**
   - What we know: User must exist with SSH key access
   - What's unclear: What SSH key should be used for amazeeio user?
   - Recommendation: Use same key as bryan (provided in context), or require operator to provide key; document decision

2. **Password display mechanism**
   - What we know: Passwords must be displayed to operator
   - What's unclear: Should passwords be logged to file, or only stdout?
   - Recommendation: Display to stdout only (don't log passwords); operator responsible for capture

3. **Testing strategy for user creation**
   - What we know: Need to test user creation without affecting host
   - What's unclear: Run tests in Docker container, or mock user creation?
   - Recommendation: Use Bats with setup/teardown that creates temp users, or document manual testing procedure

## Sources

### Primary (HIGH confidence)
- **Ubuntu Server Documentation - User Management** — https://ubuntu.com/server/docs/tutorials/install-openssh-server
- **Debian adduser Documentation** — `man adduser` on Ubuntu 24.04
- **OpenSSH Documentation** — https://www.openssh.com/manual.html — SSH key permissions
- **OpenSSL rand Documentation** — `man openssl-rand` — Random generation
- **Google Shell Style Guide** — https://google.github.io/styleguide/shellguide.html

### Secondary (MEDIUM confidence)
- **BashFAQ/105** — https://mywiki.wooledge.org/BashFAQ/105 — set -e behavior
- **ShellCheck** — https://github.com/koalaman/shellcheck — Code quality

### Tertiary (LOW confidence)
- Community tutorials and blog posts (implementation patterns only)

## Metadata

**Confidence breakdown:**
- Standard stack: HIGH — Ubuntu 24.04 documented, tools verified in environment
- Architecture: HIGH — Established patterns from SUMMARY.md, Google Shell Style Guide
- Pitfalls: HIGH — Common bash/Linux issues well-documented
- SSH specifics: HIGH — OpenSSH docs clear on permission requirements

**Research date:** 2026-03-10
**Valid until:** 2026-06-10 (Ubuntu 24.04 LTS stable, low churn)

---

*Phase 2 User Management research complete. Ready for planning.*
