---
status: testing
phase: 06-docker-core
source: 06-01-SUMMARY.md, 06-02-SUMMARY.md, 06-03-SUMMARY.md
started: 2026-03-11
updated: 2026-03-11
---

## Current Test

number: 1
name: Module Files Exist
expected: |
  All three Docker modules exist in modules/50-docker/:
  - 50-docker-engine.sh (74 lines)
  - 51-docker-compose.sh (54 lines)
  - 52-docker-config.sh (106 lines)
  All files are executable (chmod +x)
awaiting: user response

## Tests

### 1. Module Files Exist
expected: |
  All three Docker modules exist in modules/50-docker/:
  - 50-docker-engine.sh (74 lines)
  - 51-docker-compose.sh (54 lines)
  - 52-docker-config.sh (106 lines)
  All files are executable (chmod +x)
result: pending

### 2. Docker Engine Installation
expected: |
  On a fresh Ubuntu server, running ./install.sh (or the modules directly) installs Docker Engine from the official Docker repository.
  After installation: `docker --version` returns version info (e.g., "Docker version 27.x.x")
result: pending

### 3. Docker Compose Plugin
expected: |
  `docker compose version` returns version info for the Compose v2 plugin.
  Command uses space (docker compose) not hyphen (docker-compose).
result: pending

### 4. Non-Root Docker Access
expected: |
  After running 52-docker-config.sh and logging out/in:
  User can run `docker ps` and `docker run hello-world` without sudo.
  Users bryan, amazeeio, dgxc are all in the docker group.
result: pending

### 5. Docker Daemon Auto-Start
expected: |
  After system reboot, Docker daemon starts automatically.
  `systemctl is-enabled docker` returns "enabled"
  `systemctl status docker` shows active (running)
result: pending

### 6. Idempotency Check
expected: |
  Running the Docker modules multiple times does not cause errors.
  Second run should skip installation with "already installed" messages.
result: pending

## Summary

total: 6
passed: 0
issues: 0
pending: 6
skipped: 0

## Gaps

[none yet]
