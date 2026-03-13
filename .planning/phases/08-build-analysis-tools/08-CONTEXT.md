# Phase 8: Build & Analysis Tools - Context

**Gathered:** 2026-03-13
**Status:** Ready for planning

<domain>
## Phase Boundary

Install dive, BuildKit, buildx, and hadolint for image analysis and Dockerfile validation. Users can analyze Docker images layer-by-layer and validate Dockerfiles with integrated tooling.

**Success Criteria (from ROADMAP.md):**
1. User can run `dive <image>` and explore image layers interactively
2. User can run `docker buildx version` and see buildx plugin version
3. Docker builds use BuildKit by default (DOCKER_BUILDKIT=1)
4. User can run `hadolint Dockerfile` and see lint results
5. hadolint can be integrated with editor or CI pipeline

**Requirements:** DIVE-01, DIVE-02, BUILD-01, BUILD-02, LINT-01, LINT-02

</domain>

<decisions>
## Implementation Decisions

### Tool Installation Patterns

#### dive
- **Installation method:** GitHub binary release (consistent with lazydocker pattern)
- **Version strategy:** Latest release using GitHub 'latest' URL
- **Install location:** `/opt/dive/` directory with symlink to `/usr/local/bin/dive`
- **Idempotency:** Check for existing installation before downloading
- **Architecture:** Support amd64 and arm64 (x86_64/aarch64 mapping)

#### BuildKit
- **Configuration approach:** TBD — needs decision on daemon.json vs environment variable

#### buildx
- **Availability:** Modern Docker Engine includes buildx — verify vs install TBD

#### hadolint
- **Distribution method:** TBD — standalone binary, Docker image, or apt

### Claude's Discretion
- BuildKit configuration details (daemon.json structure, environment variables)
- buildx verification approach (check vs install)
- hadolint installation method
- Exact module numbering (55-dive.sh, 56-buildkit.sh, etc.)

</decisions>

<code_context>
## Existing Code Insights

### Reusable Assets
- **modules/50-docker/53-lazydocker.sh**: Complete pattern for GitHub binary installation — architecture detection, download, extraction, symlink
- **modules/50-docker/50-docker-engine.sh**: Docker apt repository pattern, systemctl usage
- **modules/50-docker/52-docker-config.sh**: Docker daemon configuration pattern
- **lib/common.sh**: log_info, log_warn, die functions for consistent logging

### Established Patterns
- **Binary installation:** `/opt/<tool>/` + symlink to `/usr/local/bin/`
- **Idempotency:** Check with `command -v` and file existence before install
- **Architecture mapping:** dpkg amd64→x86_64, arm64→aarch64
- **GitHub releases:** Use `latest/download/` URL for always-current version
- **Module numbering:** 50-docker-engine, 51-docker-compose, 52-docker-config, 53-lazydocker, 54-ctop — next available is 55+
- **Error handling:** `set -euo pipefail`, `die` for critical failures
- **Logging:** `log_info` for progress, `log_warn` for non-critical issues

### Integration Points
- **Docker daemon configuration:** May need to update `/etc/docker/daemon.json` for BuildKit
- **Environment variables:** May need `/etc/profile.d/` or similar for DOCKER_BUILDKIT=1
- **Shell integration:** hadolint should be in PATH for all users (symlink pattern)
- **Module ordering:** 55-dive.sh, 56-buildkit.sh, 57-hadolint.sh (suggested)

</code_context>

<specifics>
## Specific Ideas

- "Follow the lazydocker pattern for dive — it's proven and consistent"
- Keep all Docker-related tools in modules/50-docker/ for organization
- BuildKit should be transparent to users — just works without them thinking about it

</specifics>

<deferred>
## Deferred Ideas

None — discussion stayed within phase scope

</deferred>

---

*Phase: 08-build-analysis-tools*
*Context gathered: 2026-03-13*
