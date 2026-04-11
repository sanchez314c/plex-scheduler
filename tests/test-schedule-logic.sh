#!/bin/bash

# Test suite for is_within_schedule() in plex-scheduler.sh
# Sources the scheduler and overrides the 'date' command to inject controlled times.

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SCHEDULER_SCRIPT="$SCRIPT_DIR/../scripts/plex-scheduler.sh"

# ---------------------------------------------------------------------------
# Test harness
# ---------------------------------------------------------------------------

PASS=0
FAIL=0

# Simulated current time, set before each test via _TEST_TIME="HH:MM"
_TEST_TIME=""

# Override date to return controlled values when called with format strings
# shellcheck disable=SC2317
date() {
    case "$1" in
        '+%H') echo "${_TEST_TIME%%:*}" ;;
        '+%M') echo "${_TEST_TIME##*:}" ;;
        *) command date "$@" ;;
    esac
}
export -f date

run_test() {
    local description="$1"
    local test_time="$2"
    local start_time="$3"
    local end_time="$4"
    local expected="$5"   # "IN" or "OUT"

    # Set globals that is_within_schedule() reads
    _TEST_TIME="$test_time"
    # shellcheck disable=SC2034
    SCHEDULE_START_TIME="$start_time"
    # shellcheck disable=SC2034
    SCHEDULE_END_TIME="$end_time"

    if is_within_schedule; then
        actual="IN"
    else
        actual="OUT"
    fi

    if [ "$actual" = "$expected" ]; then
        echo "  PASS  $description"
        echo "        time=$test_time window=${start_time}-${end_time} expected=$expected"
        PASS=$((PASS + 1))
    else
        echo "  FAIL  $description"
        echo "        time=$test_time window=${start_time}-${end_time} expected=$expected got=$actual"
        FAIL=$((FAIL + 1))
    fi
}

# ---------------------------------------------------------------------------
# Source just the functions we need from plex-scheduler.sh, skipping the
# case statement at the bottom which would execute as a side effect.
# We do this by sourcing only up to the case block via a temp wrapper.
# ---------------------------------------------------------------------------

# Extract only function definitions (everything before the case block)
_FUNCS_ONLY=$(awk '/^# Parse command line arguments/{exit} {print}' "$SCHEDULER_SCRIPT")

# Evaluate the extracted functions in the current shell
eval "$_FUNCS_ONLY"

if ! declare -f is_within_schedule > /dev/null 2>&1; then
    echo "ERROR: Failed to source is_within_schedule() from $SCHEDULER_SCRIPT"
    exit 1
fi

# ---------------------------------------------------------------------------
# Test cases
# ---------------------------------------------------------------------------

echo ""
echo "=== Plex Scheduler - is_within_schedule() Test Suite ==="
echo ""
echo "--- Overnight window: 22:00 to 04:00 ---"

run_test "Exactly at start time (22:00) - should be IN" \
    "22:00" "22:00" "04:00" "IN"

run_test "Exactly at end time (04:00) - should be OUT" \
    "04:00" "22:00" "04:00" "OUT"

run_test "One minute before start (21:59) - should be OUT" \
    "21:59" "22:00" "04:00" "OUT"

run_test "One minute after start (22:01) - should be IN" \
    "22:01" "22:00" "04:00" "IN"

run_test "Midnight (00:00) - should be IN (overnight window)" \
    "00:00" "22:00" "04:00" "IN"

run_test "3:59 AM - should be IN (just before end)" \
    "03:59" "22:00" "04:00" "IN"

run_test "4:01 AM - should be OUT (just after end)" \
    "04:01" "22:00" "04:00" "OUT"

run_test "Noon (12:00) - should be OUT (midday, outside overnight window)" \
    "12:00" "22:00" "04:00" "OUT"

echo ""
echo "--- Same-day window: 09:00 to 17:00 ---"

run_test "09:00 start - should be IN" \
    "09:00" "09:00" "17:00" "IN"

run_test "17:00 end - should be OUT" \
    "17:00" "09:00" "17:00" "OUT"

run_test "12:00 midday - should be IN" \
    "12:00" "09:00" "17:00" "IN"

run_test "08:59 before window - should be OUT" \
    "08:59" "09:00" "17:00" "OUT"

run_test "17:01 after window - should be OUT" \
    "17:01" "09:00" "17:00" "OUT"

echo ""
echo "--- Edge case: same start and end time ---"

run_test "Same start/end (12:00 = 12:00) - should be OUT (undefined window)" \
    "12:00" "12:00" "12:00" "OUT"

run_test "Same start/end at midnight (00:00 = 00:00) - should be OUT" \
    "00:00" "00:00" "00:00" "OUT"

# ---------------------------------------------------------------------------
# Results
# ---------------------------------------------------------------------------

echo ""
echo "======================================="
echo "Results: $PASS passed, $FAIL failed"
echo "======================================="
echo ""

if [ "$FAIL" -gt 0 ]; then
    exit 1
fi

exit 0
