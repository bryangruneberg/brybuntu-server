# Technology Stack: Brybuntu Server Automation

**Project:** Brybuntu Server Setup  
**Target OS:** Ubuntu 24.04.3 LTS (Noble Numbat)  
**Research Date:** 2025-03-10  
**Approach:** Pure Bash with modular script architecture

---

## Executive Summary

For a bash-based Ubuntu 24.04.3 LTS server automation tool, the standard 2025 approach is to use **modern Bash 5.x** with strict mode (`set -euo pipefail`), **systemd-native service management**, and **SSH key-based authentication** with Ed25519 keys. Ubuntu 24.04 uses **adduser** (not useradd) for user management, **sudoers.d** for privilege configuration, and **systemctl** for service control.

The key insight for 2025: Ubuntu is transitioning from traditional `sudo.ws` to `sudo-rs` (Rust implementation) starting with Ubuntu 25.10, but 24.04 LTS remains on the traditional `sudo` package. Both are compatible for the project's use case.

---

## Core Stack

### Shell Environment

| Technology | Version | Purpose | Why |
|------------|---------|---------|-----|
| Bash | 5.2+ (Ubuntu 24.04 ships 5.2.21) | Script execution | Default shell, POSIX-compliant with modern features |
| `set -euo pipefail` | Built-in | Error handling | Exit on error, undefined vars, pipe failures |
| `#!/bin/bash` | Shebang | Interpreter directive | Explicit bash requirement, no POSIX sh compatibility needed |

**Confidence:** HIGH - Verified with official Bash manual and Ubuntu 24.04 package manifest

**Bash Best Practices for 2025:**
- Use `[[ ... ]]` for conditionals (not `[ ... ]]`) — prevents word splitting and globbing issues
- Use `$(command)` for command substitution (not backticks) — nestable, clearer
- Use arrays for argument lists — `${array[@]}` for safe expansion
- Use `local` for function variables — prevents namespace pollution
- Use `readonly` for constants — immutable by convention

**Avoid:**
- `eval` — security risk, munges input
- `let` or `$[ ... ]` — deprecated, use `(( ... ))` or `$(( ... ))` instead
- Unquoted variables — causes word splitting issues
- `source` without path — use `${BASH_SOURCE[0]}` for reliability

### Package Management

| Tool | Version | Purpose | Why |
|------|---------|---------|-----|
| apt | 2.7+ | Package operations | Modern, parallel downloads, progress display |
| dpkg | 1.22+ | Low-level package mgmt | Underlying package database |

**2025 Best Practice:**
```bash
# Use apt instead of apt-get for user-facing scripts (better output)
apt update && apt upgrade -y

# For non-interactive automation, use:
DEBIAN_FRONTEND=noninteractive apt install -y package
```

**Confidence:** HIGH - Ubuntu Server documentation confirms apt as primary tool

### User Management

| Tool | Version | Purpose | Why |
|------|---------|---------|-----|
| adduser | 3.137+ | Create users | Debian/Ubuntu preferred tool (higher-level than useradd) |
| usermod | - | Modify users | Standard user attribute changes |
| chpasswd | - | Set passwords | Non-interactive password setting |
| pwgen | - | Generate passwords | Secure random password generation |

**Critical Finding (HIGH confidence):**
Ubuntu explicitly recommends `adduser` over `useradd` for interactive/administrative user creation. From Ubuntu Server docs:
> "Ubuntu and other Debian-based distributions encourage the use of the `adduser` package for account management."

**Correct 2025 Pattern:**
```bash
# Create user with home directory, bash shell
adduser --disabled-password --gecos "" "$username"

# Set random password
echo "$username:$password" | chpasswd

# Add to sudo group
usermod -aG sudo "$username"
```

**What NOT to use:**
- `useradd` directly — lower-level, requires more flags for proper setup
- Manual /etc/passwd editing — error-prone, bypasses validation

### SSH Configuration

| Component | Version/Standard | Purpose |
|-----------|-----------------|---------|
| OpenSSH Server | 9.6+ (Ubuntu 24.04) | SSH daemon |
| sshd_config.d/ | Directory | Modular config snippets |
| Ed25519 | Algorithm | SSH key type (recommended) |
| authorized_keys | File format | Public key storage |

**2025 SSH Best Practices (HIGH confidence from Ubuntu Server docs):**

1. **Use modular configuration** — Place custom configs in `/etc/ssh/sshd_config.d/*.conf`
   ```bash
   # Main config includes this line at top:
   Include /etc/ssh/sshd_config.d/*.conf
   ```

2. **Ed25519 keys are recommended** — Shorter keys, faster, more secure than RSA
   ```bash
   ssh-keygen -t ed25519 -C "comment"
   ```

3. **Validate before restart** — Prevent lockouts
   ```bash
   sshd -t  # Test configuration
   systemctl restart ssh.service
   ```

4. **Proper permissions are critical:**
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/authorized_keys
   ```

**Key SSH Directives for Development Servers:**
```
PermitRootLogin prohibit-password  # Or 'no' for production
PasswordAuthentication no          # Key-only after setup
PubkeyAuthentication yes
AllowUsers user1 user2             # Restrict access
```

### Sudo Configuration

| Tool | Version | Purpose | Why |
|------|---------|---------|-----|
| sudo | 1.9.14+ | Privilege escalation | Standard Ubuntu tool |
| sudoers.d/ | Directory | Modular sudo config | Keeps configs separate, manageable |
| visudo | Editor wrapper | Safe sudoers editing | Syntax validation |

**Important 2025 Context:**
Ubuntu 25.10+ will transition to `sudo-rs` (Rust rewrite). Ubuntu 24.04 LTS uses traditional `sudo`. Both support the same `sudoers.d/` configuration pattern.

**Best Practice Pattern:**
```bash
# Create a sudoers drop-in file
cat > /etc/sudoers.d/99-custom << 'EOF'
# Allow sudo group passwordless sudo
%sudo ALL=(ALL:ALL) NOPASSWD: ALL
EOF

chmod 440 /etc/sudoers.d/99-custom
```

**Confidence:** HIGH - Verified in Ubuntu Server user management documentation

### Service Management

| Tool | Version | Purpose | Why |
|------|---------|---------|-----|
| systemctl | systemd 255+ | Service control | Native systemd interface |
| systemd | 255+ | Init system | Ubuntu 24.04 uses systemd |

**2025 Patterns:**
```bash
# Check service status
systemctl is-active ssh.service

# Restart service
systemctl restart ssh.service

# Enable on boot
systemctl enable ssh.service
```

---

## Script Architecture Patterns

### Modular Execution (Numbered Scripts)

Based on the project requirements for "numbered files in subdirectories, executed in order":

```
scripts/
├── 00-update-system/
│   └── 10-update-packages.sh
├── 10-users/
│   ├── 10-create-users.sh
│   ├── 20-configure-sudo.sh
│   └── 30-setup-ssh-keys.sh
├── 20-ssh/
│   └── 10-configure-ssh.sh
└── 99-cleanup/
    └── 10-finalize.sh
```

**Execution Pattern:**
```bash
# Run scripts in order across all directories
for dir in scripts/*/; do
    for script in "$dir"/*.sh; do
        [[ -f "$script" ]] && bash "$script"
    done
done
```

### Script Template (2025 Standard)

```bash
#!/bin/bash
set -euo pipefail

# Script metadata
readonly SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
readonly SCRIPT_NAME="$(basename "$0")"

# Logging functions
log_info() { echo "[INFO] $*"; }
log_error() { echo "[ERROR] $*" >&2; }

# Error handler
cleanup() {
    local exit_code=$?
    [[ $exit_code -ne 0 ]] && log_error "Script failed with exit code $exit_code"
}
trap cleanup EXIT

main() {
    log_info "Starting ${SCRIPT_NAME}..."
    # Script logic here
    log_info "Completed ${SCRIPT_NAME}"
}

main "$@"
```

### Configuration Management

For a simple bash-based tool, avoid complex config systems. Use:

1. **Environment variables** for runtime overrides
2. **Sourced config files** for user customization
3. **Sensible defaults** in the scripts

```bash
# config.sh - sourced by main script
USERS_TO_CREATE="${USERS_TO_CREATE:-bryan amazeeio}"
SSH_KEY_PATH="${SSH_KEY_PATH:-/root/.ssh/id_ed25519.pub}"
TIMEZONE="${TIMEZONE:-UTC}"
```

---

## Testing & Quality Assurance

| Tool | Purpose | Installation |
|------|---------|--------------|
| ShellCheck | Static analysis | `apt install shellcheck` |
| shfmt | Shell formatting | Download binary or use editor plugin |
| Bats | Bash testing framework | Optional for unit tests |

**ShellCheck (HIGHLY RECOMMENDED):**
```bash
# Check all scripts
shellcheck scripts/**/*.sh

# In CI, fail on warnings:
shellcheck --severity=warning scripts/**/*.sh
```

ShellCheck catches:
- Unquoted variables (word splitting)
- Deprecated syntax
- Potential security issues
- Common logic errors

**Confidence:** HIGH - ShellCheck is the industry standard, used by Google, GitHub, etc.

---

## Security Considerations

### Password Generation

Use `/dev/urandom` or `openssl` for cryptographically secure passwords:

```bash
# Generate 32-character random password
generate_password() {
    openssl rand -base64 24 | tr -d "=+/" | cut -c1-32
}
```

### SSH Key Handling

```bash
# Never log private keys
# Set correct permissions immediately
install_ssh_key() {
    local user="$1"
    local key="$2"
    local user_home
    user_home=$(getent passwd "$user" | cut -d: -f6)
    
    mkdir -p "${user_home}/.ssh"
    echo "$key" >> "${user_home}/.ssh/authorized_keys"
    chmod 700 "${user_home}/.ssh"
    chmod 600 "${user_home}/.ssh/authorized_keys"
    chown -R "$user:$user" "${user_home}/.ssh"
}
```

### Script Security

1. **Never use `eval`** with user input
2. **Quote all variables** in command arguments
3. **Use `[[` not `[`** for conditionals
4. **Validate inputs** before use
5. **Use `set -euo pipefail`** to catch errors early

---

## Alternatives Considered

| Alternative | Why Not Chosen | When to Use Instead |
|-------------|----------------|---------------------|
| Ansible | Adds Python dependency, agentless but complex | Multi-server orchestration, idempotent operations |
| cloud-init | Requires image customization, not post-boot | Initial server provisioning on cloud providers |
| Chef/Puppet | Heavyweight, requires infrastructure | Large-scale fleet management |
| POSIX sh | Missing bash features (arrays, [[ ]]) | Extreme portability requirements (embedded) |
| Python scripts | Adds interpreter dependency | Complex logic, data structures needed |

**Confidence:** HIGH - This matches the project's constraint of "pure bash, modular architecture"

---

## Version Verification

| Component | Ubuntu 24.04 Version | Source |
|-----------|---------------------|--------|
| Bash | 5.2.21 | packages.ubuntu.com |
| OpenSSH | 9.6p1 | packages.ubuntu.com |
| systemd | 255.4 | packages.ubuntu.com |
| apt | 2.7.14 | packages.ubuntu.com |
| sudo | 1.9.15p5 | packages.ubuntu.com |

**Confidence:** HIGH - Verified against official Ubuntu package repositories

---

## Key Decisions Summary

| Decision | Rationale | Confidence |
|----------|-----------|------------|
| Use `adduser` not `useradd` | Ubuntu/Debian recommended tool | HIGH |
| Use Ed25519 SSH keys | Modern, secure, recommended by Ubuntu | HIGH |
| Use `sudoers.d/` files | Modular, manageable privilege config | HIGH |
| Use `set -euo pipefail` | Modern bash error handling | HIGH |
| Use ShellCheck | Industry standard for bash quality | HIGH |
| Avoid `eval` | Security risk, unnecessary | HIGH |
| Numbered script execution | Clear ordering without complex deps | MEDIUM |

---

## Sources

1. **Ubuntu Server Documentation** - https://ubuntu.com/server/docs
   - User management: https://ubuntu.com/server/docs/how-to/security/user-management
   - OpenSSH: https://ubuntu.com/server/docs/how-to/security/openssh-server

2. **Bash Reference Manual** - https://www.gnu.org/software/bash/manual/bash.html
   - Version 5.3 (latest)

3. **Google Shell Style Guide** - https://google.github.io/styleguide/shellguide.html
   - Industry best practices

4. **ShellCheck Documentation** - https://github.com/koalaman/shellcheck
   - Static analysis for bash

5. **Securing Debian Manual** - https://www.debian.org/doc/manuals/securing-debian-manual/
   - Security hardening guidance

---

## Research Gaps / Open Questions

1. **sudo-rs transition timeline** — While 24.04 uses traditional sudo, understanding migration path for future LTS is useful
2. **Ubuntu Pro integration** — If targeting enterprise, Ubuntu Pro features may affect stack
3. **Cloud-init coexistence** — Some cloud providers run cloud-init; understanding interaction patterns
