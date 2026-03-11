# Agent Instructions for Brybuntu Server Setup

## Project Overview

This is a **server provisioning project** - scripts to configure NEW Ubuntu servers from scratch. It is NOT meant to be run on the development workstation.

## ⚠️ CRITICAL RULE: No Local Execution

**NEVER** run any module scripts on the current machine (bryarchy). These scripts are designed to be run on FRESH Ubuntu servers during initial setup.

- DO NOT run `install.sh` on the development machine
- DO NOT execute any module in `modules/` locally
- DO NOT run `apt-get install` commands from modules
- DO NOT test installation scripts locally

## What You CAN Do

- Write and edit module scripts
- Review and fix bugs in the code
- Validate syntax with `bash -n`
- Create tests in `tests/` directory
- Update documentation

## What You CANNOT Do

- Execute installation scripts locally
- Install packages on the development machine
- Modify system configuration on the development machine
- Generate SSH keys on the development machine (unless explicitly requested)

## Module Creation Pattern

When creating new modules:

1. Write the script following existing patterns
2. Make it executable with `chmod +x`
3. Validate syntax with `bash -n`
4. STOP - do not execute it

## Testing Approach

- Test scripts are in `tests/` and use BATS framework
- Manual testing happens on actual target servers, not locally
- Local validation is limited to syntax checks only

## File Patterns

- `modules/**/*.sh` - Installation scripts (NEVER RUN LOCALLY)
- `lib/*.sh` - Shared libraries (safe to source for syntax validation)
- `tests/**/*.bats` - Test files (safe to run with BATS)
- `install.sh` - Main orchestrator (NEVER RUN LOCALLY)

## Enforcement

If a user asks you to "test" or "run" a module:
- Ask for confirmation: "These scripts are for server provisioning. Should I execute this on the local machine?"
- Default answer is NO unless explicitly confirmed for a valid reason
