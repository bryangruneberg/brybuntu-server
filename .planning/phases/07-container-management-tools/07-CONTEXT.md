# Phase 7: Container Management Tools - Context

**Gathered:** 2026-03-11
**Status:** Ready for planning

<domain>
## Phase Boundary

Install TUI (Terminal User Interface) tools for Docker container management and monitoring. Users get intuitive terminal-based interfaces for managing containers (lazydocker) and monitoring resource usage (ctop).

**Requirements covered:** LAZY-01, LAZY-02, CTOP-01, CTOP-02

**Depends on:** Phase 6 (Docker Core must be installed first)

</domain>

<decisions>
## Implementation Decisions

### lazydocker Installation
- Install from **official binary release** on GitHub
- Download latest stable release (no version pinning)
- Install location: `/opt/lazydocker/` directory
- Create symlink in `/usr/local/bin/lazydocker` for PATH access
- Idempotency: Check if binary exists before downloading

### ctop Installation
- Install via **package manager (apt)**
- Use `apt-get install ctop` if available in Ubuntu repos
- Fallback to binary release if apt package unavailable
- Latest stable version

### Module Organization
- **Separate focused modules** following Phase 6 pattern:
  - `53-lazydocker.sh` — Download and install lazydocker binary
  - `54-ctop.sh` — Install ctop via apt
- Each module handles one tool independently
- Both modules in `modules/50-docker/` directory

### Tool Availability
- Both tools must be in PATH for all users (bryan, amazeeio, dgxc)
- No additional user configuration required
- Tools work immediately after installation

### Claude's Discretion
- Exact download URL construction for lazydocker releases
- Architecture detection (amd64, arm64) for binary selection
- Fallback strategy if ctop not in apt repos
- Symlink vs direct copy decision for lazydocker

</decisions>

<specifics>
## Specific Ideas

- lazydocker provides an interactive dashboard for containers, images, volumes, and networks
- ctop shows real-time metrics similar to htop but for containers
- Both tools should work out-of-the-box with the Docker setup from Phase 6
- Follow the same patterns as Node.js and Docker modules: check-before-install idempotency

</specifics>

<code_context>
## Existing Code Insights

### Reusable Assets
- `lib/common.sh` — Logging functions (log_info, log_warn, die), check_root()
- `modules/50-docker/50-docker-engine.sh` — Pattern for installing external binaries
- `modules/40-dev/10-node.sh` — Pattern for repository-based installation

### Established Patterns
- **Source guard pattern** — All library files use `if [[ -n "${VAR:-}" ]]; then return 0; fi`
- **Idempotency** — Check if already installed before proceeding
- **Strict mode** — `set -euo pipefail` in all modules
- **Error handling** — Use `|| die "message"` for critical operations
- **Logging** — Use log_info/log_warn from common.sh
- **DEBIAN_FRONTEND=noninteractive** — Prevents apt interactive prompts
- **External binaries** — Download to /opt/, symlink to /usr/local/bin/

### Integration Points
- Modules go in `modules/50-docker/` with `53-*` and `54-*` prefixes
- Execute after Phase 6 Docker modules (50-*, 51-*, 52-*)
- Both tools integrate with Docker daemon from Phase 6
- No user-specific configuration needed (system-wide tools)

</code_context>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope.

</deferred>

---

*Phase: 07-container-management-tools*
*Context gathered: 2026-03-11*
