---
phase: quick
plan: 6
type: execute
wave: 1
depends_on: []
files_modified:
  - modules/50-docker/53-lazydocker.sh
autonomous: true
requirements:
  - FIX-LAZYDOCKER-404
must_haves:
  truths:
    - lazydocker installation script fetches the latest version successfully
    - URL construction uses proper GitHub release tag format
    - Script validates the download before extraction
  artifacts:
    - path: modules/50-docker/53-lazydocker.sh
      provides: "Fixed lazydocker installation script with API-based version detection"
      exports: ["install_lazydocker"]
  key_links:
    - from: "53-lazydocker.sh"
      to: "GitHub API"
      via: "curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest"
      pattern: "tag_name.*v[0-9]"
---

<objective>
Fix the lazydocker installation module (53-lazydocker.sh) that fails with 404 error because GitHub doesn't support direct downloads from the "latest" release endpoint with a filename.

Purpose: Allow the server provisioning script to successfully install lazydocker on fresh Ubuntu servers.
Output: Updated module script that fetches the actual latest version tag from GitHub API and constructs the correct download URL.
</objective>

<execution_context>
@./.opencode/get-shit-done/workflows/execute-plan.md
</execution_context>

<context>
@modules/50-docker/53-lazydocker.sh

## Problem Analysis

**Current broken URL:**
```
https://github.com/jesseduffield/lazydocker/releases/latest/download/lazydocker_latest_Linux_x86_64.tar.gz
```

**Root cause:** GitHub's `/releases/latest/download/` endpoint doesn't support specifying filenames. It only works for the auto-generated "latest" redirect, not for versioned filenames.

**Correct URL format (from API):**
```
https://github.com/jesseduffield/lazydocker/releases/download/v0.24.4/lazydocker_0.24.4_Linux_x86_64.tar.gz
```

**Solution:** Use GitHub API to get the latest release tag, then construct the correct URL:
```bash
latest_version=$(curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest | grep '"tag_name":' | sed -E 's/.*"([^"]+)".*/\1/' | sed 's/^v//')
download_url="https://github.com/jesseduffield/lazydocker/releases/download/v${latest_version}/lazydocker_${latest_version}_Linux_${lazydocker_arch}.tar.gz"
```

**Architecture mapping (keep existing):**
- amd64 → x86_64
- arm64 → arm64 (aarch64 renamed to arm64 in lazydocker releases)
</context>

<tasks>

<task type="auto">
  <name>Task 1: Fix lazydocker download URL to use GitHub API</name>
  <files>modules/50-docker/53-lazydocker.sh</files>
  <action>
    Update the install_lazydocker() function in modules/50-docker/53-lazydocker.sh to:

    1. Query GitHub API to get the latest release tag
       - Use: curl -s https://api.github.com/repos/jesseduffield/lazydocker/releases/latest
       - Extract tag_name field and strip the 'v' prefix for the version

    2. Fix architecture mapping (lazydocker uses "arm64" not "aarch64"):
       - amd64 → x86_64
       - arm64 → arm64

    3. Construct correct download URL using the actual version tag:
       - Format: https://github.com/jesseduffield/lazydocker/releases/download/v${VERSION}/lazydocker_${VERSION}_Linux_${ARCH}.tar.gz

    4. Add error handling if the API call fails (die with clear message)

    Replace lines 49-52 (the download_url assignment and surrounding curl) with:
    - API query to get latest version
    - URL construction using the version
    - Existing curl command (but now with working URL)
  </action>
  <verify>
    <automated>bash -n modules/50-docker/53-lazydocker.sh</automated>
  </verify>
  <done>Script syntax validates successfully, architecture mapping updated, download URL construction uses GitHub API response</done>
</task>

<task type="auto">
  <name>Task 2: Add download URL validation</name>
  <files>modules/50-docker/53-lazydocker.sh</files>
  <action>
    Add URL validation before the curl download:

    1. After constructing the download_url, validate it resolves correctly:
       - Use curl -fsSLI "$download_url" --head to check URL exists (returns 200)
       - If validation fails, die with message showing the constructed URL

    2. Update the error message in the existing curl -fsSL line to include the URL for debugging

    This ensures that even if the API changes format, we get a clear error message instead of a 404.
  </action>
  <verify>
    <automated>bash -n modules/50-docker/53-lazydocker.sh</automated>
  </verify>
  <done>Script includes URL validation that checks the download URL exists before attempting download</done>
</task>

</tasks>

<verification>
- Script validates with `bash -n` (no syntax errors)
- Script follows existing code patterns (logging, error handling with die, idempotency checks)
- Architecture mapping is correct for lazydocker release filenames
- GitHub API integration extracts version correctly
- URL construction matches actual GitHub release asset URLs
</verification>

<success_criteria>
1. `bash -n modules/50-docker/53-lazydocker.sh` returns exit code 0
2. Script correctly queries GitHub API to get latest version tag
3. Script constructs valid download URLs that would return 200 (not 404)
4. Architecture mapping updated: amd64→x86_64, arm64→arm64
5. Error handling for API failures with clear messages
</success_criteria>

<output>
After completion, create `.planning/quick/6-fix-lazydocker-404-error/6-SUMMARY.md`
</output>
