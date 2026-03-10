---
phase: 3
slug: access-control
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2026-03-10
---

# Phase 3 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Bats (Bash Automated Testing System) |
| **Config file** | `tests/bats/bats.conf` — existing |
| **Quick run command** | `bats tests/test_sudo_config.bats` |
| **Full suite command** | `bats tests/` |
| **Estimated runtime** | ~5 seconds |

---

## Sampling Rate

- **After every task commit:** Run `shellcheck` on new/modified scripts
- **After every plan wave:** Run Bats tests for sudo configuration
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 3-01-01 | 01 | 1 | SUDO-01, SUDO-02 | static | `shellcheck modules/30-sudo/10-sudoers.sh` | ❌ W0 | ⬜ pending |
| 3-01-02 | 01 | 1 | SUDO-03, SUDO-04 | static | `shellcheck tests/test_sudo_config.bats` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `lib/sudo.sh` — sudo configuration helper functions (if needed)
- [ ] `modules/30-sudo/` — directory for sudo configuration modules
- [ ] Bats testing framework installed (from Phase 2)
- [ ] `tests/test_sudo_config.bats` — test stubs for sudoers validation

*Wave 0 may not be needed if using existing test infrastructure*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| Actual sudo access | SUDO-01, SUDO-02 | Requires running as target user | 1. SSH as bryan/amazeeio 2. Run `sudo whoami` 3. Verify returns "root" without password |
| Sudoers file permissions | SUDO-04 | Requires root to check /etc/sudoers.d/ | 1. Run `ls -la /etc/sudoers.d/bryan` 2. Verify mode 440 |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
