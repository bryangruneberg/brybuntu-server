#!/bin/bash
# Test suite for modules/10-system/10-update.sh

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
if [[ -f "$PROJECT_ROOT/modules/10-system/10-update.sh" ]]; then
    pass "10-update.sh exists"
else
    fail "10-update.sh does not exist"
fi

# Test 2: Valid bash syntax
if bash -n "$PROJECT_ROOT/modules/10-system/10-update.sh" 2>/dev/null; then
    pass "10-update.sh has valid bash syntax"
else
    fail "10-update.sh has bash syntax errors"
fi

# Test 3: Has correct shebang
if head -1 "$PROJECT_ROOT/modules/10-system/10-update.sh" | grep -q "#!/bin/bash"; then
    pass "10-update.sh has correct shebang"
else
    fail "10-update.sh missing correct shebang"
fi

# Test 4: Sets strict mode
if grep -q "set -euo pipefail" "$PROJECT_ROOT/modules/10-system/10-update.sh"; then
    pass "10-update.sh uses strict mode"
else
    fail "10-update.sh missing strict mode"
fi

# Test 5: Sources common.sh correctly
if grep -q 'source "$(dirname "$0")/../../lib/common.sh"' "$PROJECT_ROOT/modules/10-system/10-update.sh"; then
    pass "10-update.sh sources common.sh with correct relative path"
else
    fail "10-update.sh missing or incorrect common.sh source"
fi

# Test 6: Sets DEBIAN_FRONTEND=noninteractive
if grep -q "DEBIAN_FRONTEND=noninteractive" "$PROJECT_ROOT/modules/10-system/10-update.sh"; then
    pass "10-update.sh sets DEBIAN_FRONTEND=noninteractive"
else
    fail "10-update.sh missing DEBIAN_FRONTEND setting"
fi

# Test 7: Runs apt-get update
if grep -q "apt-get update" "$PROJECT_ROOT/modules/10-system/10-update.sh"; then
    pass "10-update.sh runs apt-get update"
else
    fail "10-update.sh missing apt-get update"
fi

# Test 8: Has error handling (|| die pattern)
if grep -q "|| die" "$PROJECT_ROOT/modules/10-system/10-update.sh"; then
    pass "10-update.sh uses || die error handling"
else
    fail "10-update.sh missing || die error handling"
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
