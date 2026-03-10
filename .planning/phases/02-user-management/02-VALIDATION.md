---
phase: 2
slug: user-management
status: draft
nyquist_compliant: false
wave_0_complete: false
created: 2025-03-10
---

# Phase 2 — Validation Strategy

> Per-phase validation contract for feedback sampling during execution.

---

## Test Infrastructure

| Property | Value |
|----------|-------|
| **Framework** | Bats (Bash Automated Testing System) |
| **Config file** | `tests/bats/bats.conf` — if not exists, Wave 0 creates |
| **Quick run command** | `bats tests/test_user_management.bats` |
| **Full suite command** | `bats tests/` |
| **Estimated runtime** | ~10 seconds |

---

## Sampling Rate

- **After every task commit:** Run `shellcheck` on new/modified scripts
- **After every plan wave:** Run Bats tests for user management
- **Before `/gsd-verify-work`:** Full suite must be green
- **Max feedback latency:** 10 seconds

---

## Per-Task Verification Map

| Task ID | Plan | Wave | Requirement | Test Type | Automated Command | File Exists | Status |
|---------|------|------|-------------|-----------|-------------------|-------------|--------|
| 2-01-01 | 01 | 1 | USER-01..04 | static | `shellcheck modules/20-users/10-bryan.sh` | ❌ W0 | ⬜ pending |
| 2-01-02 | 01 | 1 | USER-05..08 | static | `shellcheck modules/20-users/20-amazeeio.sh` | ❌ W0 | ⬜ pending |
| 2-02-01 | 02 | 2 | ALL | integration | `bats tests/test_user_management.bats` | ❌ W0 | ⬜ pending |

*Status: ⬜ pending · ✅ green · ❌ red · ⚠️ flaky*

---

## Wave 0 Requirements

- [ ] `lib/user.sh` — user management helper functions (create_user, setup_ssh)
- [ ] `modules/20-users/` — directory for user creation modules
- [ ] Bats testing framework installed
- [ ] `tests/test_user_management.bats` — test stubs

*Wave 0 creates reusable user management library and test infrastructure*

---

## Manual-Only Verifications

| Behavior | Requirement | Why Manual | Test Instructions |
|----------|-------------|------------|-------------------|
| SSH key authentication | USER-02, USER-04, USER-06, USER-08 | Requires actual SSH connection | 1. Run install.sh 2. `ssh bryan@server` with Ed25519 key 3. Verify no password prompt |
| Password randomness | USER-02, USER-06 | Requires manual inspection | 1. Run install.sh 2. Check displayed passwords are different each run 3. Verify length ~44 chars |
| .ssh permissions | USER-03, USER-04, USER-07, USER-08 | Requires actual filesystem | 1. Run install.sh 2. `ls -la /home/bryan/.ssh` 3. Verify 700 on dir, 600 on authorized_keys |

---

## Validation Sign-Off

- [ ] All tasks have `<automated>` verify or Wave 0 dependencies
- [ ] Sampling continuity: no 3 consecutive tasks without automated verify
- [ ] Wave 0 covers all MISSING references
- [ ] No watch-mode flags
- [ ] Feedback latency < 10s
- [ ] `nyquist_compliant: true` set in frontmatter

**Approval:** pending
