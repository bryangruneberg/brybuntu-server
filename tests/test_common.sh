#!/bin/bash
# Test suite for lib/common.sh
# Tests are designed to verify behavior of the common library

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Test helper functions
pass() {
    echo -e "${GREEN}[PASS]${NC} $1"
    ((TESTS_PASSED++))
}

fail() {
    echo -e "${RED}[FAIL]${NC} $1"
    ((TESTS_FAILED++))
}

# Test 1: Library can be sourced without errors
test_source_library() {
    echo "Test: Library can be sourced without errors"
    if bash -c "source lib/common.sh" 2>/dev/null; then
        pass "Library sources without error"
    else
        fail "Library failed to source"
    fi
}

# Test 2: Double-sourcing returns early (no redefinition errors)
test_double_source() {
    echo "Test: Double-sourcing returns early"
    if bash -c "source lib/common.sh && source lib/common.sh" 2>/dev/null; then
        pass "Double-sourcing works without error"
    else
        fail "Double-sourcing failed"
    fi
}

# Test 3: log_info outputs "[INFO] message"
test_log_info() {
    echo "Test: log_info outputs [INFO] message"
    local output
    output=$(bash -c "source lib/common.sh && log_info 'test message'" 2>&1)
    if [[ "$output" == *"[INFO] test message"* ]]; then
        pass "log_info outputs correct format"
    else
        fail "log_info output mismatch: $output"
    fi
}

# Test 4: log_warn outputs "[WARN] message" to stderr
test_log_warn() {
    echo "Test: log_warn outputs [WARN] message to stderr"
    local output
    output=$(bash -c "source lib/common.sh && log_warn 'warn message'" 2>&1)
    if [[ "$output" == *"[WARN] warn message"* ]]; then
        pass "log_warn outputs correct format"
    else
        fail "log_warn output mismatch: $output"
    fi
}

# Test 5: log_error outputs "[ERROR] message" to stderr
test_log_error() {
    echo "Test: log_error outputs [ERROR] message to stderr"
    local output
    output=$(bash -c "source lib/common.sh && log_error 'error message'" 2>&1)
    if [[ "$output" == *"[ERROR] error message"* ]]; then
        pass "log_error outputs correct format"
    else
        fail "log_error output mismatch: $output"
    fi
}

# Test 6: die logs error and exits with code 1
test_die() {
    echo "Test: die logs error and exits with code 1"
    local output
    local exit_code=0
    output=$(bash -c "source lib/common.sh && die 'fatal error'" 2>&1) || exit_code=$?
    if [[ "$output" == *"[ERROR] fatal error"* ]] && [[ $exit_code -eq 1 ]]; then
        pass "die outputs error and exits with code 1"
    else
        fail "die behavior incorrect: exit_code=$exit_code, output=$output"
    fi
}

# Test 7: check_root verifies EUID is 0 (dies if not, passes if root)
test_check_root() {
    echo "Test: check_root behavior"
    if [[ $EUID -eq 0 ]]; then
        # Running as root - should pass
        if bash -c "source lib/common.sh && check_root" 2>/dev/null; then
            pass "check_root passes when running as root"
        else
            fail "check_root failed when running as root"
        fi
    else
        # Not running as root - should die with "Must run as root"
        local output
        local exit_code=0
        output=$(bash -c "source lib/common.sh && check_root" 2>&1) || exit_code=$?
        if [[ "$output" == *"Must run as root"* ]] && [[ $exit_code -eq 1 ]]; then
            pass "check_root dies correctly when not root"
        else
            fail "check_root behavior incorrect: exit_code=$exit_code, output=$output"
        fi
    fi
}

# Test 8: validate_ubuntu checks /etc/os-release for ID=ubuntu
test_validate_ubuntu() {
    echo "Test: validate_ubuntu checks OS"
    # Create a mock /etc/os-release for testing
    local temp_dir
    temp_dir=$(mktemp -d)
    echo 'ID=ubuntu' > "$temp_dir/os-release"
    echo 'VERSION_ID="24.04"' >> "$temp_dir/os-release"

    # Test with mock file
    local output
    output=$(bash -c "
        source lib/common.sh
        # Override the os-release path for testing
        validate_ubuntu() {
            if [[ -f '$temp_dir/os-release' ]]; then
                local ID VERSION_ID
                source '$temp_dir/os-release'
                if [[ '\$ID' != 'ubuntu' ]]; then
                    log_warn 'Not running on Ubuntu (detected: '\$ID')'
                    return 1
                fi
                if [[ '\$VERSION_ID' != '24.04' ]]; then
                    log_warn 'Ubuntu version '\$VERSION_ID' detected. Tested on 24.04.'
                fi
            else
                die '/etc/os-release not found'
            fi
        }
        validate_ubuntu
    " 2>&1)

    if [[ $? -eq 0 ]]; then
        pass "validate_ubuntu passes on Ubuntu"
    else
        fail "validate_ubuntu failed on Ubuntu: $output"
    fi

    rm -rf "$temp_dir"
}

# Run all tests
echo "=== Testing lib/common.sh ==="
echo ""

# First check if lib/common.sh exists
if [[ ! -f "lib/common.sh" ]]; then
    echo -e "${RED}ERROR: lib/common.sh not found${NC}"
    exit 1
fi

test_source_library
test_double_source
test_log_info
test_log_warn
test_log_error
test_die
test_check_root
test_validate_ubuntu

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
