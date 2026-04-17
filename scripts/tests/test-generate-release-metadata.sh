#!/bin/sh
set -eu
# Tests for generate-release-metadata.sh epoch fallback and validation (T10).

SCRIPTS_DIR="$(cd "$(dirname "$0")/.." && pwd)"
pass=0
fail=0

assert_contains() {
  label=$1
  file=$2
  pattern=$3
  if grep -q "$pattern" "$file"; then
    printf 'PASS: %s\n' "$label"
    pass=$((pass + 1))
  else
    printf 'FAIL: %s -- pattern not found: %s\n' "$label" "$pattern" >&2
    fail=$((fail + 1))
  fi
}

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

# Create a minimal dummy ZIP for testing (sha256 still works on non-ZIP data).
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

dummy_zip="$tmpdir/onlinebrief24-2026-04-17.zip"
dummy_ann="$tmpdir/announcement.txt"
printf 'dummy zip content' > "$dummy_zip"
printf 'Test announcement.' > "$dummy_ann"
output="$tmpdir/release-metadata.json"

# Test epoch fallback: run without PREPARE_RUN_ID or GITHUB_RUN_ID so the
# script falls back to $(date -u +%s).
env -i PATH="$PATH" HOME="$HOME" \
  sh "$SCRIPTS_DIR/generate-release-metadata.sh" \
    "$dummy_zip" "$dummy_ann" "$output"

assert_contains "schema_version present" "$output" '"schema_version": 1'
assert_contains "package_name present"   "$output" '"package_name": "onlinebrief24"'
assert_contains "version extracted"      "$output" '"version": "2026-04-17"'
assert_contains "prepare_run_id present" "$output" '"prepare_run_id":'

# Test validation: non-integer prepare_run_id must be rejected.
assert_fail "non-integer prepare_run_id" \
  env PREPARE_RUN_ID="not-a-number" \
  sh "$SCRIPTS_DIR/generate-release-metadata.sh" \
    "$dummy_zip" "$dummy_ann" "$tmpdir/out-bad.json"

# Test validation: non-integer prepare_run_attempt must be rejected.
assert_fail "non-integer prepare_run_attempt" \
  env PREPARE_RUN_ATTEMPT="not-a-number" \
  sh "$SCRIPTS_DIR/generate-release-metadata.sh" \
    "$dummy_zip" "$dummy_ann" "$tmpdir/out-bad2.json"

# Test validation: artifact filename with invalid month must be rejected.
invalid_month_zip="$tmpdir/onlinebrief24-2026-13-01.zip"
printf 'dummy zip content' > "$invalid_month_zip"
assert_fail "invalid month in artifact filename" \
  sh "$SCRIPTS_DIR/generate-release-metadata.sh" \
    "$invalid_month_zip" "$dummy_ann" "$tmpdir/out-bad3.json"

# Test validation: artifact filename with invalid day must be rejected.
invalid_day_zip="$tmpdir/onlinebrief24-2026-04-00.zip"
printf 'dummy zip content' > "$invalid_day_zip"
assert_fail "invalid day in artifact filename" \
  sh "$SCRIPTS_DIR/generate-release-metadata.sh" \
    "$invalid_day_zip" "$dummy_ann" "$tmpdir/out-bad4.json"

printf '\n%d passed, %d failed\n' "$pass" "$fail"
[ "$fail" -eq 0 ]
