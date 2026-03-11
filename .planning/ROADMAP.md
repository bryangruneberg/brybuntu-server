# Brybuntu Server Setup - Roadmap

**Granularity:** Coarse  
**Core Value:** New Ubuntu server → SSH-ready development environment in one command

---

## Milestones

- ✅ **v2.1 DGXC User Addition** — Phases 1-5 (shipped 2026-03-11) — [Details](milestones/v2.1-ROADMAP.md)
- 🔄 **v2.2 Docker Development Environment** — Phases 6-8 (in progress)

---

## Phases

### v2.2 Docker Development Environment

- [ ] **Phase 6: Docker Core** - Install and configure Docker Engine, CLI, and Compose plugin for all admin users
- [ ] **Phase 7: Container Management Tools** - Install lazydocker TUI and ctop for interactive container management and monitoring
- [ ] **Phase 8: Build & Analysis Tools** - Install dive, BuildKit, buildx, and hadolint for image analysis and Dockerfile validation

<details>
<summary>✅ v2.1 DGXC User Addition (Phases 1-5) — SHIPPED 2026-03-11</summary>

### Phase 1: Core Infrastructure
- [x] 01-01: Create shared library and orchestrator
- [x] 01-02: Create system update modules

### Phase 2: User Management
- [x] 02-01: Create user library and bryan user module
- [x] 02-02: Create amazeeio user module

### Phase 3: Access Control
- [x] 03-01: Create sudo library and bryan sudoers module
- [x] 03-02: Create amazeeio sudoers module

### Phase 4: Development Environment
- [x] 04-01: Install Node.js and Opencode CLI
- [x] 04-02: Install Neovim and LazyVim for both users

### Phase 5: dgxc User Addition
- [x] 05-01: Create dgxc user, sudo, and LazyVim modules

</details>

---

## Phase Details

### Phase 6: Docker Core
**Goal:** All admin users can run Docker containers without root privileges
**Depends on:** Phase 5 (previous milestone)
**Requirements:** DOCK-01, DOCK-02, DOCK-03, DOCK-04, DOCK-05
**Success Criteria** (what must be TRUE):
  1. Admin user can run `docker run hello-world` without sudo
  2. Admin user can check Docker version with `docker --version`
  3. Admin user can run `docker compose version` and see version output
  4. Docker daemon starts automatically after system reboot
  5. Admin user can list containers with `docker ps`
**Plans:** 3 plans (Wave 1: parallel engine + compose, Wave 2: config)
- [ ] 06-01-PLAN.md — Install Docker Engine and CLI from official repository
- [ ] 06-02-PLAN.md — Install Docker Compose v2 plugin
- [ ] 06-03-PLAN.md — Configure docker group and auto-start for all users

### Phase 7: Container Management Tools
**Goal:** Users have intuitive TUI tools for monitoring and managing containers
**Depends on:** Phase 6
**Requirements:** LAZY-01, LAZY-02, CTOP-01, CTOP-02
**Success Criteria** (what must be TRUE):
  1. User can launch lazydocker by typing `lazydocker` and see container dashboard
  2. lazydocker displays running containers with logs, stats, and controls
  3. User can run `ctop` and see real-time CPU/memory metrics for all containers
  4. ctop shows container resource usage updating in real-time
**Plans**: TBD

### Phase 8: Build & Analysis Tools
**Goal:** Users can analyze Docker images and validate Dockerfiles with integrated tooling
**Depends on:** Phase 7
**Requirements:** DIVE-01, DIVE-02, BUILD-01, BUILD-02, LINT-01, LINT-02
**Success Criteria** (what must be TRUE):
  1. User can run `dive <image>` and explore image layers interactively
  2. User can run `docker buildx version` and see buildx plugin version
  3. Docker builds use BuildKit by default (DOCKER_BUILDKIT=1)
  4. User can run `hadolint Dockerfile` and see lint results
  5. hadolint can be integrated with editor or CI pipeline
**Plans**: TBD

---

## Requirements Coverage

### v2.2 Requirements (12 total)

| Category | Requirement | Phase | Status |
|----------|-------------|-------|--------|
| Docker Core | DOCK-01 | 6 | Pending |
| Docker Core | DOCK-02 | 6 | Pending |
| Docker Core | DOCK-03 | 6 | Pending |
| Docker Core | DOCK-04 | 6 | Pending |
| Docker Core | DOCK-05 | 6 | Pending |
| Container Tools | LAZY-01 | 7 | Pending |
| Container Tools | LAZY-02 | 7 | Pending |
| Container Tools | CTOP-01 | 7 | Pending |
| Container Tools | CTOP-02 | 7 | Pending |
| Build Tools | DIVE-01 | 8 | Pending |
| Build Tools | DIVE-02 | 8 | Pending |
| Build Tools | BUILD-01 | 8 | Pending |
| Build Tools | BUILD-02 | 8 | Pending |
| Build Tools | LINT-01 | 8 | Pending |
| Build Tools | LINT-02 | 8 | Pending |

**Coverage:** 12/12 requirements mapped ✓

---

## Progress

| Phase | Milestone | Plans | Status | Completed |
|-------|-----------|-------|--------|-----------|
| 1. Core Infrastructure | v2.1 | 2/2 | ✅ Complete | 2026-03-10 |
| 2. User Management | v2.1 | 2/2 | ✅ Complete | 2026-03-10 |
| 3. Access Control | v2.1 | 2/2 | ✅ Complete | 2026-03-10 |
| 4. Development Environment | v2.1 | 2/2 | ✅ Complete | 2026-03-10 |
| 5. dgxc User Addition | v2.1 | 1/1 | ✅ Complete | 2026-03-11 |
| 6. Docker Core | v2.2 | 0/3 | Not started | - |
| 7. Container Management Tools | v2.2 | 0/2 | Not started | - |
| 8. Build & Analysis Tools | v2.2 | 0/3 | Not started | - |

---

*Last updated: 2026-03-11 after roadmap creation for v2.2*
