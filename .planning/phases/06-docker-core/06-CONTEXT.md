# Phase 6: Docker Core - Context

**Gathered:** 2026-03-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Install and configure Docker Engine, CLI, and Compose plugin for all admin users (bryan, amazeeio, dgxc). Users must be able to run Docker containers without root privileges after setup completes.

**Requirements covered:** DOCK-01, DOCK-02, DOCK-03, DOCK-04, DOCK-05

</domain>

<decisions>
## Implementation Decisions

### Docker Installation Source
- Install from **Docker's official apt repository** (not Ubuntu universe)
- Packages: docker-ce, docker-ce-cli, containerd.io
- Gets latest stable version with security updates

### Docker Compose
- Install as **Docker Compose v2 CLI plugin** (modern approach)
- Command: `docker compose` (space, not hyphen)
- Installed via apt from Docker repository

### Non-Root Access
- Add all three admin users to **docker group**: bryan, amazeeio, dgxc
- Standard approach: group membership grants Docker daemon access
- Users will need to log out and back in for group changes to take effect

### Module Organization
- **Separate focused modules** following existing codebase pattern:
  - `50-docker-engine.sh` — Install Docker Engine daemon and CLI
  - `50-docker-compose.sh` — Install Docker Compose plugin
  - `50-docker-config.sh` — Add users to docker group, enable daemon

### Version Strategy
- **Latest stable** from Docker repository
- No version pinning — gets security updates automatically
- Idempotency via package manager (apt)

### Auto-Start Configuration
- Docker daemon must start automatically on boot
- Enable and start systemd service

### Claude's Discretion
- Exact module file naming within 50-* range
- Specific apt repository setup method (curl vs manual sources.list)
- Whether to install docker-buildx-plugin alongside compose
- Handling of users who might already be in docker group (idempotency)

</decisions>

<specifics>
## Specific Ideas

- Follow the same pattern as Node.js installation: check if already installed, use apt repository setup
- Docker installation will require adding Docker's GPG key and apt repository
- Consider displaying a message about logout/login requirement for docker group
- Module order: engine first, then compose, then user configuration

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/common.sh` — Logging functions (log_info, log_warn, die), check_root(), DEBIAN_FRONTEND=noninteractive pattern
- Module pattern from `modules/40-dev/10-node.sh` — Repository setup via curl, idempotency check with command -v
- User/group management patterns from `lib/user.sh` — Using standard Linux tools

### Established Patterns
- **Source guard pattern** — All library files use `if [[ -n "${VAR:-}" ]]; then return 0; fi`
- **Idempotency** — Check if already installed before proceeding (command -v, dpkg -l, etc.)
- **Strict mode** — `set -euo pipefail` in all modules
- **Error handling** — Use `|| die "message"` for critical operations
- **Logging** — Use log_info/log_warn from common.sh, not echo
- **DEBIAN_FRONTEND=noninteractive** — Prevents apt interactive prompts

### Integration Points
- Modules go in `modules/` subdirectories with `50-*` prefix (suggested: `modules/50-docker/`)
- Main orchestrator `install.sh` discovers and executes modules automatically via `discover_modules()`
- Docker modules should execute after system updates (10-system/) and development tools (40-dev/)
- Users already exist from phases 2 and 5 — just need group membership added

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 06-docker-core*
*Context gathered: 2026-03-11*
