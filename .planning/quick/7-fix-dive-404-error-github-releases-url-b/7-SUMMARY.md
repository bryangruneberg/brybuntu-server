---
phase: quick-7
plan: 7
subsystem: docker
tags: [docker, dive, github-releases, bug-fix]
dependency_graph:
  requires: []
  provides: [working-dive-installation]
  affects: [modules/50-docker/55-dive.sh]
tech_stack:
  added: []
  patterns: [github-api-version-query, url-validation, idempotent-installation]
key_files:
  created: []
  modified:
    - modules/50-docker/55-dive.sh
decisions:
  - Applied same GitHub API pattern as lazydocker fix for consistency
  - Preserved existing architecture mappings (x86_64, aarch64)
  - Added URL validation before download attempt
metrics:
  duration: 5m
  completed_date: "2026-03-13"
---

# Quick Task 7: Fix dive 404 Error - GitHub Releases URL Summary

## One-Liner
Fixed dive installation module's broken GitHub releases URL by implementing GitHub API version detection and URL validation, following the same pattern as the working lazydocker implementation.

## What Was Changed

The dive installation script (`modules/50-docker/55-dive.sh`) was using a broken URL format that returned 404 errors:
- **Before:** `https://github.com/wagoodman/dive/releases/latest/download/dive_Linux_${arch}.tar.gz`
- **After:** `https://github.com/wagoodman/dive/releases/download/v${version}/dive_${version}_Linux_${arch}.tar.gz`

### Changes Made

1. **Added GitHub API version query** (lines 49-52):
   - Queries `api.github.com/repos/wagoodman/dive/releases/latest`
   - Extracts version tag and strips 'v' prefix
   - Validates version was retrieved before proceeding

2. **Updated URL construction** (lines 60-62):
   - Uses correct format: `releases/download/v${version}/...`
   - Includes version number in both path and filename

3. **Added URL validation** (lines 64-68):
   - Validates URL exists with `curl -fsSLI` before download
   - Fails fast with clear error message if URL is invalid

## Verification

- ✅ Script passes `bash -n` syntax validation
- ✅ GitHub API query pattern present for wagoodman/dive
- ✅ Download URL uses correct format with version number
- ✅ URL validation with curl -fsSLI included before download
- ✅ Architecture mapping preserved (x86_64 for amd64, aarch64 for arm64)
- ✅ Pattern matches working 53-lazydocker.sh implementation

## Commits

- `e3c690a`: fix(quick-7): fix dive GitHub releases URL to use API for version detection

## Deviations from Plan

None - plan executed exactly as written.

## Self-Check: PASSED

- [x] File exists: modules/50-docker/55-dive.sh
- [x] Commit exists: e3c690a
- [x] All required patterns verified
