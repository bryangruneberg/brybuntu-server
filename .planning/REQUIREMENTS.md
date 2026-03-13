# Requirements: Brybuntu Server Setup — v2.2 Docker Development Environment

**Defined:** 2026-03-11
**Core Value:** New Ubuntu server → SSH-ready development environment in one command, now with Docker containerization

---

## v2.2 Requirements

### Docker Core

- [x] **DOCK-01**: Docker Engine installed and daemon running
- [x] **DOCK-02**: Docker CLI available for all admin users
- [x] **DOCK-03**: Docker Compose plugin installed
- [x] **DOCK-04**: All admin users added to docker group for non-root access
- [x] **DOCK-05**: Docker daemon starts automatically on boot

### Container Management Tools

- [x] **LAZY-01**: lazydocker installed and available in PATH
- [x] **LAZY-02**: lazydocker can connect to local Docker daemon
- [x] **CTOP-01**: ctop installed for container resource monitoring
- [x] **CTOP-02**: ctop displays running containers with CPU/memory metrics

### Build & Analysis Tools

- [x] **DIVE-01**: dive installed for image layer analysis
- [x] **DIVE-02**: dive can analyze local and remote images
- [ ] **BUILD-01**: BuildKit enabled by default
- [ ] **BUILD-02**: docker buildx plugin available
- [ ] **LINT-01**: hadolint installed for Dockerfile linting
- [ ] **LINT-02**: hadolint integrates with editor/CI workflows

---

## v3.0 Requirements (Future)

### Security & Registry

- **TRIV-01**: trivy installed for image vulnerability scanning
- **SKOP-01**: skopeo for image copying between registries
- **REGCTL-01**: regctl for registry operations

### Orchestration

- **KUBE-01**: kubectl for Kubernetes cluster management
- **K9S-01**: k9s TUI for Kubernetes
- **HELM-01**: helm for Kubernetes package management

---

## Out of Scope

| Feature | Reason |
|---------|--------|
| Kubernetes cluster setup | Infrastructure scope — this milestone focuses on client tools only |
| Private registry setup | Not needed for development workflow |
| Docker Swarm mode | Compose sufficient for local development |
| GPU support (nvidia-docker) | Hardware-specific, not universally applicable |
| Rootless Docker | Adds complexity; docker group sufficient for dev environment |

---

## Traceability

| Requirement | Phase | Status |
|-------------|-------|--------|
| DOCK-01 | Phase 6 | Complete |
| DOCK-02 | Phase 6 | Complete |
| DOCK-03 | Phase 6 | Complete |
| DOCK-04 | Phase 6 | Complete |
| DOCK-05 | Phase 6 | Complete |
| LAZY-01 | Phase 7 | Complete |
| LAZY-02 | Phase 7 | Complete |
| CTOP-01 | Phase 7 | Complete |
| CTOP-02 | Phase 7 | Complete |
| DIVE-01 | Phase 8 | Complete |
| DIVE-02 | Phase 8 | Complete |
| BUILD-01 | Phase 8 | Pending |
| BUILD-02 | Phase 8 | Pending |
| LINT-01 | Phase 8 | Pending |
| LINT-02 | Phase 8 | Pending |

**Coverage:**
- v2.2 requirements: 12 total
- Mapped to phases: 12
- Unmapped: 0 ✓

---

## Phase Mappings

### Phase 6: Docker Core
Requirements: DOCK-01, DOCK-02, DOCK-03, DOCK-04, DOCK-05

### Phase 7: Container Management Tools
Requirements: LAZY-01, LAZY-02, CTOP-01, CTOP-02

### Phase 8: Build & Analysis Tools
Requirements: DIVE-01, DIVE-02, BUILD-01, BUILD-02, LINT-01, LINT-02

---

*Requirements defined: 2026-03-11*
*Last updated: 2026-03-11 after roadmap creation for v2.2*
