#!/bin/sh
set -eu
# Tests for bump-version.sh argument validation (T09).
# Only exercises the validation path — does not write to any repository file.

SCRIPTS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
pass=0
fail=0

assert_fail() {
  label=$1
  shift
  if "$@" > /dev/null 2>&1; then
    printf 'FAIL: %s -- expected failure but succeeded\n' "$label" >&2
    fail=$((fail + 1))
  else
    printf 'PASS: %s\n' "$label"
    pass=$((pass + 1))
  fi
}

assert_fail "non-date string" sh "$SCRIPTS_DIR/bump-version.sh" "not-a-date"
assert_fail "semver input"    sh "$SCRIPTS_DIR/bump-version.sh" "1.2.3"
assert_fail "partial date"    sh "$SCRIPTS_DIR/bump-version.sh" "2026-01"
assert_fail "month 00"        sh "$SCRIPTS_DIR/bump-version.sh" "2026-00-01"
assert_fail "month 13"        sh "$SCRIPTS_DIR/bump-version.sh" "2026-13-01"
assert_fail "day 00"          sh "$SCRIPTS_DIR/bump-version.sh" "2026-01-00"
assert_fail "day 32"          sh "$SCRIPTS_DIR/bump-version.sh" "2026-01-32"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
