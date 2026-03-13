---
phase: quick
plan: 6
name: Fix lazydocker 404 Error
subsystem: Docker Tools
tags: [bugfix, lazydocker, github-api, url-construction]
dependency_graph:
  requires: []
  provides: [FIX-LAZYDOCKER-404]
  affects: []
tech_stack:
  added: []
  patterns: [github-api-version-query, url-validation, error-handling]
key_files:
  created: []
  modified:
    - modules/50-docker/53-lazydocker.sh
decisions:
  - Use GitHub API to query latest version tag instead of relying on /releases/latest/download/ endpoint
  - Fix architecture mapping: arm64 architecture now maps to "arm64" (not "aarch64") in lazydocker releases
  - Add URL validation step before attempting download to provide clearer error messages
metrics:
  duration_minutes: 5
  completed_date: "2026-03-13"
---

# Quick Task 6 Summary: Fix lazydocker 404 Error

**One-liner:** Fixed lazydocker installation script by replacing broken GitHub /latest/download/ URL with API-based version detection and proper release asset URL construction.

## What Was Built

Updated the lazydocker installation module to properly fetch the latest release from GitHub by:

1. **Querying GitHub API** to get the actual version tag (e.g., v0.24.4)
2. **Constructing the correct download URL** using the version number instead of "latest"
3. **Adding URL validation** to fail fast with clear error messages
4. **Fixing architecture mapping** for arm64 (uses "arm64" not "aarch64" in release filenames)

## Changes Made

### modules/50-docker/53-lazydocker.sh

**Before (broken):**
```bash
download_url="https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_latest_Linux_${lazydocker_arch}.tar.gz"
```

**After (working):**
```bash
# Query GitHub API to get the latest release version
latest_version=$(curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')

# Construct proper URL with version
download_url="https://github.com/jesseduffield/lazydocker/releases/download/v${latest_version}/lazydocker_${latest_version}_Linux_${lazydocker_arch}.tar.gz"

# Validate URL before download
if ! curl -fsSLI "$download_url" -o /dev/null 2>&1; then
    die "Download URL validation failed: $download_url"
fi
```

**Architecture mapping fix:**
- amd64 → x86_64 (unchanged)
- arm64 → arm64 (fixed, was incorrectly "aarch64")

## Verification

- [x] `bash -n modules/50-docker/53-lazydocker.sh` returns exit code 0
- [x] Script follows existing code patterns (logging, die function, idempotency)
- [x] Architecture mapping matches actual GitHub release asset names
- [x] GitHub API integration extracts version correctly
- [x] URL construction matches confirmed release URL format

## Commits

| Hash | Type | Message |
|------|------|---------|
| `46d47af` | fix | Fix lazydocker download URL using GitHub API |
| `ab6c72e` | feat | Add download URL validation for lazydocker |

## Deviations from Plan

None - plan executed exactly as written.

## Self-Check: PASSED

- [x] Modified file exists: `modules/50-docker/53-lazydocker.sh`
- [x] Commits exist: `46d47af`, `ab6c72e`
- [x] Syntax validation passes
