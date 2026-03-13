---
phase: quick-7
plan: 7
type: execute
wave: 1
depends_on: []
files_modified: [modules/50-docker/55-dive.sh]
autonomous: true
requirements: [QUICK-7]
must_haves:
  truths:
    - dive module uses correct GitHub releases URL format
    - dive downloads successfully without 404 error
    - dive installation includes URL validation
  artifacts:
    - path: "modules/50-docker/55-dive.sh"
      provides: "dive installation with correct GitHub API-based URL construction"
      min_lines: 100
  key_links:
    - from: "55-dive.sh"
      to: "api.github.com"
      via: "curl -s for version tag"
      pattern: "curl -s.*api.github.com.*releases/latest"
    - from: "55-dive.sh"
      to: "github.com/wagoodman/dive/releases"
      via: "correct URL format with version tag"
      pattern: "releases/download/v\\${version}"
---

<objective>
Fix the dive installation module's GitHub releases URL to use the correct format with version number instead of the broken "latest/download" format.

Purpose: The current URL format `latest/download/dive_Linux_x86_64.tar.gz` returns 404. The correct format requires querying the GitHub API for the latest version tag and constructing the URL as `releases/download/v${version}/dive_${version}_Linux_${arch}.tar.gz`.

Output: Updated modules/50-docker/55-dive.sh that follows the same pattern as 53-lazydocker.sh
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/execute-plan.md
@./.opencode/get-shit-done/templates/summary.md
</execution_context>

<context>
@.planning/STATE.md
@modules/50-docker/53-lazydocker.sh
@modules/50-docker/55-dive.sh

## Current Broken Implementation (55-dive.sh lines 50-51)
```bash
local download_url
download_url="https://github.com/wagoodman/dive/releases/latest/download/dive_Linux_${dive_arch}.tar.gz"
```

## Working Implementation (53-lazydocker.sh lines 49-62)
```bash
# Query GitHub API to get the latest release version
log_info "Querying GitHub API for latest lazydocker version..."
local latest_version
latest_version=$(curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')

if [[ -z "$latest_version" ]]; then
    die "Failed to determine latest lazydocker version from GitHub API"
fi

log_info "Latest lazydocker version: v${latest_version}"

# Download latest release from GitHub
local download_url
download_url="https://github.com/jesseduffield/lazydocker/releases/download/v${latest_version}/lazydocker_${latest_version}_Linux_${lazydocker_arch}.tar.gz"

# Validate the download URL exists before attempting download
log_info "Validating download URL..."
if ! curl -fsSLI "$download_url" -o /dev/null 2>&1; then
    die "Download URL validation failed: $download_url"
fi
```

## Key Differences for dive

1. **Repository:** wagoodman/dive (not jesseduffield/lazydocker)
2. **Version format:** May have "v" prefix, need to check actual releases
3. **Architecture mapping:** 
   - amd64 -> x86_64
   - arm64 -> aarch64 (note: lazydocker uses "arm64" for arm64)
4. **Filename format:** Based on task description, appears to be `dive_${version}_Linux_${arch}.tar.gz`

## URL Validation Pattern
Use `curl -fsSLI "$download_url" -o /dev/null 2>&1` to check URL exists before download (as in lazydocker fix).
</context>

<tasks>

<task type="auto">
  <name>Task 1: Fix dive GitHub releases URL to use API for version detection</name>
  <files>modules/50-docker/55-dive.sh</files>
  <action>
Update modules/50-docker/55-dive.sh to fix the broken GitHub releases URL by:

1. Replace the hardcoded URL (lines 50-51) with GitHub API version detection following the lazydocker pattern

2. Add GitHub API query to get latest version:
```bash
# Query GitHub API to get the latest release version
log_info "Querying GitHub API for latest dive version..."
local latest_version
latest_version=$(curl -s https://api.github.com/repos/wagoodman/dive/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')

if [[ -z "$latest_version" ]]; then
    die "Failed to determine latest dive version from GitHub API"
fi

log_info "Latest dive version: v${latest_version}"
```

3. Update URL construction to use correct format with version number:
```bash
local download_url
download_url="https://github.com/wagoodman/dive/releases/download/v${latest_version}/dive_${latest_version}_Linux_${dive_arch}.tar.gz"
```

4. Add URL validation before download (after URL construction, before curl download):
```bash
# Validate the download URL exists before attempting download
log_info "Validating download URL..."
if ! curl -fsSLI "$download_url" -o /dev/null 2>&1; then
    die "Download URL validation failed: $download_url"
fi
```

5. Keep existing architecture mapping (x86_64 for amd64, aarch64 for arm64)

The architecture mappings are already correct:
- amd64 -> x86_64
- arm64 -> aarch64
</action>
  <verify>
    <automated>bash -n modules/50-docker/55-dive.sh && echo "Syntax OK"</automated>
  </verify>
  <done>Script syntax is valid and follows the working lazydocker pattern for GitHub API version detection and URL validation</done>
</task>

<task type="auto">
  <name>Task 2: Verify URL format correctness</name>
  <files>modules/50-docker/55-dive.sh</files>
  <action>
Verify the corrected URL format by checking that the script:

1. Uses the correct repository (wagoodman/dive)
2. Queries the GitHub API at https://api.github.com/repos/wagoodman/dive/releases/latest
3. Constructs URL in format: https://github.com/wagoodman/dive/releases/download/v${version}/dive_${version}_Linux_${arch}.tar.gz
4. Strips the 'v' prefix from the version tag when constructing filename
5. Includes URL validation with curl -fsSLI

Run a syntax check and grep to confirm the patterns are present:
- Check for api.github.com URL
- Check for releases/download pattern
- Check for URL validation curl command
</action>
  <verify>
    <automated>grep -E "api.github.com/repos/wagoodman/dive/releases/latest" modules/50-docker/55-dive.sh && grep -E "releases/download/v\$\{latest_version\}" modules/50-docker/55-dive.sh && grep -E "curl -fsSLI.*download_url.*-o /dev/null" modules/50-docker/55-dive.sh && echo "All patterns found"</automated>
  </verify>
  <done>All required patterns are present: GitHub API query, correct download URL format with version, and URL validation</done>
</task>

</tasks>

<verification>
- Script passes bash syntax validation
- GitHub API query pattern is present for wagoodman/dive
- Download URL uses correct format: releases/download/v${version}/dive_${version}_Linux_${arch}.tar.gz
- URL validation with curl -fsSLI is included before download
- Architecture mapping preserved (x86_64, aarch64)
- Script follows the same pattern as 53-lazydocker.sh (proven working)
</verification>

<success_criteria>
- modules/50-docker/55-dive.sh has valid bash syntax
- Script queries GitHub API for latest version tag
- Script constructs download URL with version number in correct format
- Script validates URL exists before attempting download
- Pattern matches the working 53-lazydocker.sh implementation
</success_criteria>

<output>
After completion, create `.planning/quick/7-fix-dive-404-error-github-releases-url-b/7-SUMMARY.md`
</output>
