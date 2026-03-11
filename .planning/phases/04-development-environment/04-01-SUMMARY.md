# Phase 04 Plan 01: Node.js and Opencode CLI Installation - Summary

**Phase:** 04-development-environment  
**Plan:** 01  
**Status:** Complete ✓  
**Completed:** 2026-03-10  
**Committed:** feat(v2.0): add Node.js and Opencode installation modules

---

## What Was Accomplished

Installed Node.js LTS and Opencode CLI globally on the server:

1. **Node.js LTS** - Installed via NodeSource repository
   - Downloads and executes official setup script
   - Idempotent: skips if already installed
   - Provides `node` and `npm` system-wide

2. **Opencode CLI** - Installed via direct binary download from GitHub
   - Downloads latest release from GitHub releases
   - Supports x64 and arm64 architectures
   - Handles baseline builds for CPUs without AVX2
   - Installs to /usr/local/bin for system-wide access

## Files Created

```
modules/40-dev/
├── 10-node.sh      # Node.js LTS installation
└── 20-opencode.sh  # Opencode CLI installation
```

## Key Implementation Details

### Node.js Module (10-node.sh)
- Uses NodeSource setup_lts.x script
- Installs curl, ca-certificates, gnupg as dependencies
- Sets DEBIAN_FRONTEND=noninteractive for automation
- Logs version numbers on success

### Opencode Module (20-opencode.sh)
- `detect_target()` - Detects architecture and AVX2 support
- `get_latest_version()` - Fetches latest release from GitHub API
- Downloads binary from GitHub releases (opencode-linux-{arch}.tar.gz)
- Extracts and installs to /usr/local/bin/opencode
- Independent of npm/Node.js

## Idempotency

Both modules implement check-before-create:
- Node.js: `command -v node` check
- Opencode: `command -v opencode` check

## Success Criteria Validation

- ✅ `node --version` returns v20.x+
- ✅ `npm --version` works
- ✅ `opencode --version` works globally

## Technical Decisions

1. **NodeSource over Ubuntu repo**: Gets latest LTS instead of outdated Ubuntu packages
2. **GitHub releases for Opencode**: Official distribution method, no npm package available
3. **Baseline builds**: Automatically detects AVX2 support for compatibility
4. **Independent modules**: 20-opencode.sh doesn't depend on Node.js (different installation methods)

## Next Steps

Completed. Next is Plan 02: Neovim and LazyVim installation.

---
*Summary created retroactively to document completed work*
