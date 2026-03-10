---
phase: 1
slug: core-infrastructure
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2025-03-10
---

# Phase 1 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | bash + ShellCheck |
| **Config file** | none — static analysis only |
| **Quick run command** | `shellcheck install.sh lib/*.sh` |
| **Full suite command** | `find . -name '*.sh' -exec shellcheck {} \;` |
| **Estimated runtime** | ~5 seconds |

---

## Sampling Rate

- **After every task commit:** Run `shellcheck` on new/modified scripts
- **After every plan wave:** Full ShellCheck on all .sh files
- **Before `/gsd-verify-work`:** Full ShellCheck must pass
- **Max feedback latency:** 5 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 1-01-01 | 01 | 1 | CORE-01 | static | `shellcheck install.sh` | ❌ W0 | ⬜ pending |
| 1-01-02 | 01 | 1 | CORE-03 | static | `shellcheck lib/common.sh` | ❌ W0 | ⬜ pending |
| 1-01-03 | 01 | 1 | SYS-01,02 | manual | `apt update` && `apt list kitty-terminfo` | N/A | ⬜ pending |
| 1-02-01 | 02 | 2 | CORE-02 | integration | Run install.sh, verify execution order | N/A | ⬜ pending |
| 1-02-02 | 02 | 2 | CORE-04 | idempotency | Run install.sh twice, verify no errors | N/A | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `lib/common.sh` — logging and error handling utilities
- [ ] `10-system/` — directory for system setup modules
- [ ] ShellCheck installed for static analysis

*Wave 0 creates the foundation that all other tasks depend on*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Module execution order | CORE-02 | Requires fresh Ubuntu VM | 1. Create numbered test scripts 2. Run install.sh 3. Verify execution order matches filenames |
| Idempotency on re-run | CORE-04 | Requires fresh Ubuntu VM | 1. Run install.sh on fresh system 2. Run install.sh again 3. Verify no errors, state unchanged |
| kitty-terminfo installed | SYS-02 | Requires Ubuntu system | 1. Run install.sh 2. Verify `apt list --installed | grep kitty-terminfo` shows package |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 5s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
