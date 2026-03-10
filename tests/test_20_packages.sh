#!/bin/bash
# Test suite for modules/10-system/20-packages.sh

set -euo pipefail

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
pass() {
    echo "✓ PASS: $1"
    ((TESTS_PASSED++)) || true
}

fail() {
    echo "✗ FAIL: $1"
    ((TESTS_FAILED++)) || true
}

# Test 1: Script exists
if [[ -f "$PROJECT_ROOT/modules/10-system/20-packages.sh" ]]; then
    pass "20-packages.sh exists"
else
    fail "20-packages.sh does not exist"
fi

# Test 2: Valid bash syntax
if bash -n "$PROJECT_ROOT/modules/10-system/20-packages.sh" 2>/dev/null; then
    pass "20-packages.sh has valid bash syntax"
else
    fail "20-packages.sh has bash syntax errors"
fi

# Test 3: Has correct shebang
if head -1 "$PROJECT_ROOT/modules/10-system/20-packages.sh" | grep -q "#!/bin/bash"; then
    pass "20-packages.sh has correct shebang"
else
    fail "20-packages.sh missing correct shebang"
fi

# Test 4: Sets strict mode
if grep -q "set -euo pipefail" "$PROJECT_ROOT/modules/10-system/20-packages.sh"; then
    pass "20-packages.sh uses strict mode"
else
    fail "20-packages.sh missing strict mode"
fi

# Test 5: Sources common.sh correctly
if grep -q 'source "$(dirname "$0")/../../lib/common.sh"' "$PROJECT_ROOT/modules/10-system/20-packages.sh"; then
    pass "20-packages.sh sources common.sh with correct relative path"
else
    fail "20-packages.sh missing or incorrect common.sh source"
fi

# Test 6: Checks for package before install (idempotency)
if grep -q "dpkg -l" "$PROJECT_ROOT/modules/10-system/20-packages.sh" && \
   grep -q 'grep -q "\^ii"' "$PROJECT_ROOT/modules/10-system/20-packages.sh"; then
    pass "20-packages.sh checks if package is already installed (idempotency)"
else
    fail "20-packages.sh missing idempotency check"
fi

# Test 7: Has install logic
if grep -q "apt-get install" "$PROJECT_ROOT/modules/10-system/20-packages.sh"; then
    pass "20-packages.sh runs apt-get install"
else
    fail "20-packages.sh missing apt-get install"
fi

# Test 8: Has error handling (|| die pattern)
if grep -q "|| die" "$PROJECT_ROOT/modules/10-system/20-packages.sh"; then
    pass "20-packages.sh uses || die error handling"
else
    fail "20-packages.sh missing || die error handling"
fi

# Test 9: Uses -y flag for non-interactive install
if grep -q "apt-get install.*-y" "$PROJECT_ROOT/modules/10-system/20-packages.sh"; then
    pass "20-packages.sh uses -y flag for non-interactive install"
else
    fail "20-packages.sh missing -y flag"
fi

# Summary
echo ""
echo "========================================"
echo "Test Results: $TESTS_PASSED passed, $TESTS_FAILED failed"
echo "========================================"

if [[ $TESTS_FAILED -eq 0 ]]; then
    exit 0
else
    exit 1
fi
