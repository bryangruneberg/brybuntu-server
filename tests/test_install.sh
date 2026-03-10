#!/bin/bash
# Test suite for install.sh

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m'

TESTS_PASSED=0
TESTS_FAILED=0

pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++)) || true
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++)) || true
}

# Test 1: Script has valid syntax
test_syntax() {
    echo "Test: install.sh has valid bash syntax"
    if bash -n install.sh 2>/dev/null; then
        pass "Syntax is valid"
    else
        fail "Syntax error detected"
    fi
}

# Test 2: Script sources common.sh
test_sources_common() {
    echo "Test: install.sh sources lib/common.sh"
    if grep -q "source.*lib/common.sh" install.sh; then
        pass "Sources common.sh correctly"
    else
        fail "Does not source common.sh"
    fi
}

# Test 3: Script uses strict mode
test_strict_mode() {
    echo "Test: install.sh uses strict mode (set -euo pipefail)"
    if grep -q "set -euo pipefail" install.sh; then
        pass "Uses strict mode"
    else
        fail "Missing strict mode"
    fi
}

# Test 4: Script defines SCRIPT_DIR
test_script_dir() {
    echo "Test: install.sh defines SCRIPT_DIR"
    if grep -q "SCRIPT_DIR=" install.sh; then
        pass "Defines SCRIPT_DIR"
    else
        fail "Missing SCRIPT_DIR definition"
    fi
}

# Test 5: Script discovers modules with find pattern
test_module_discovery() {
    echo "Test: install.sh discovers modules with [0-9][0-9]-*.sh pattern"
    if grep -qE "find.*\[0-9\]\[0-9\]-\*\.sh" install.sh || grep -qE "find.*[0-9][0-9]-\*\.sh" install.sh; then
        pass "Has module discovery pattern"
    else
        fail "Missing module discovery pattern"
    fi
}

# Test 6: Script sorts modules
test_module_sort() {
    echo "Test: install.sh sorts modules"
    if grep -q "sort" install.sh; then
        pass "Sorts modules"
    else
        fail "Does not sort modules"
    fi
}

# Test 7: Script has main function
test_main_function() {
    echo "Test: install.sh has main function"
    if grep -qE "^main\(\)" install.sh || grep -qE "function main" install.sh; then
        pass "Has main function"
    else
        fail "Missing main function"
    fi
}

# Test 8: Script calls main at end
test_main_call() {
    echo "Test: install.sh calls main at end"
    if grep -qE '^main\s+"\$@"' install.sh || grep -qE '^main\s+\$@' install.sh; then
        pass "Calls main with arguments"
    else
        fail "Does not call main"
    fi
}

# Test 9: Script checks for root
test_check_root() {
    echo "Test: install.sh calls check_root"
    if grep -q "check_root" install.sh; then
        pass "Calls check_root"
    else
        fail "Missing check_root call"
    fi
}

# Test 10: Script validates Ubuntu
test_validate_ubuntu() {
    echo "Test: install.sh calls validate_ubuntu"
    if grep -q "validate_ubuntu" install.sh; then
        pass "Calls validate_ubuntu"
    else
        fail "Missing validate_ubuntu call"
    fi
}

# Test 11: Script has error handling for modules
test_module_error_handling() {
    echo "Test: install.sh has error handling for module execution"
    if grep -qE "die.*[Mm]odule" install.sh || grep -qE "||.*die" install.sh; then
        pass "Has module error handling"
    else
        fail "Missing module error handling"
    fi
}

# Run all tests
echo "=== Testing install.sh ==="
echo ""

if [[ ! -f "install.sh" ]]; then
    echo -e "${RED}ERROR: install.sh not found${NC}"
    exit 1
fi

test_syntax
test_sources_common
test_strict_mode
test_script_dir
test_module_discovery
test_module_sort
test_main_function
test_main_call
test_check_root
test_validate_ubuntu
test_module_error_handling

echo ""
echo "=== Test Results ==="
echo "Passed: $TESTS_PASSED"
echo "Failed: $TESTS_FAILED"

if [[ $TESTS_FAILED -gt 0 ]]; then
    exit 1
else
    echo -e "${GREEN}All tests passed!${NC}"
    exit 0
fi
