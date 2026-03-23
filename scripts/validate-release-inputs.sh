#!/bin/sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  printf '%s\n' "Usage: sh scripts/validate-release-inputs.sh <bundle-dir> [expected-prepare-run-id]" >&2
  exit 1
fi

bundle_dir=$1
expected_prepare_run_id=${2:-}
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/lib/common.sh"

repo_root=$(repo_root_from_dir "$script_dir")
metadata_path="$bundle_dir/release-metadata.json"

require_dir "$bundle_dir" "Prepared release bundle directory not found: $bundle_dir"
require_file "$metadata_path" "Prepared release metadata not found: $metadata_path"

# Parse and validate the JSON contract in Python so the shell only deals with
# already-normalized scalar values.
metadata_values=$(python3 "$script_dir/lib/release_validation.py" validate-metadata "$metadata_path")

eval "$metadata_values"

artifact_path="$bundle_dir/$ARTIFACT_FILENAME"
checksum_path="$artifact_path.sha256"
announcement_path="$bundle_dir/$ANNOUNCEMENT_FILENAME"

# When a specific prepare run is requested, the bundle must prove it originated
# from that exact run rather than from another artifact with similar contents.
if [ -n "$expected_prepare_run_id" ] && [ "$PREPARE_RUN_ID" != "$expected_prepare_run_id" ]; then
  printf '%s\n' "Prepared release bundle run ID $PREPARE_RUN_ID does not match requested run ID $expected_prepare_run_id" >&2
  exit 1
fi

require_file "$artifact_path" "Prepared artifact ZIP not found: $artifact_path"
require_file "$checksum_path" "Prepared checksum file not found: $checksum_path"
require_file "$announcement_path" "Prepared announcement draft not found: $announcement_path"

announcement_trimmed=$(python3 "$script_dir/lib/release_validation.py" read-announcement "$announcement_path")

# POSIX sh does not guarantee that set -e exits on a non-zero command
# substitution used in an assignment, so we guard explicitly.
if [ -z "$announcement_trimmed" ]; then
  printf '%s\n' "Prepared announcement draft is empty or whitespace only: $announcement_path" >&2
  exit 1
fi

checksum_value=$(awk 'NR==1 { print $1 }' "$checksum_path")
checksum_target=$(awk 'NR==1 { print $2 }' "$checksum_path")
actual_checksum=$(sha256sum "$artifact_path" | awk '{print $1}')

# Cross-check metadata, checksum file, and actual artifact bytes. All three must
# agree before the bundle is considered releasable.
if [ "$checksum_value" != "$ARTIFACT_SHA256" ]; then
  printf '%s\n' "release-metadata.json SHA256 does not match checksum file." >&2
  exit 1
fi

if [ "$actual_checksum" != "$ARTIFACT_SHA256" ]; then
  printf '%s\n' "Prepared artifact SHA256 does not match release metadata." >&2
  exit 1
fi

if [ "$checksum_target" != "$ARTIFACT_FILENAME" ]; then
  printf '%s\n' "Checksum file must reference artifact filename '$ARTIFACT_FILENAME' but references '$checksum_target'." >&2
  exit 1
fi

# Guard against stale upload metadata: the frozen release version must match
# the versions embedded in the package files inside the ZIP that CTAN receives.
artifact_versions=$(python3 "$script_dir/lib/release_validation.py" validate-zip "$artifact_path" "$VERSION")

eval "$artifact_versions"

if ! git -C "$repo_root" rev-parse --verify "${SOURCE_COMMIT_SHA}^{commit}" >/dev/null 2>&1; then
  printf '%s\n' "Prepared source commit is not available locally: $SOURCE_COMMIT_SHA" >&2
  exit 1
fi

# Print the resolved identifiers so release logs show exactly which artifact and
# commit were accepted for publishing.
printf '%s\n' "Validated prepared release bundle: $bundle_dir"
printf '%s\n' "Prepared artifact: $ARTIFACT_FILENAME"
printf '%s\n' "Prepared version: $VERSION"
printf '%s\n' "Artifact class version: $ARTIFACT_CLASS_VERSION"
printf '%s\n' "Artifact doc version: $ARTIFACT_DOC_VERSION"
printf '%s\n' "Prepared commit: $SOURCE_COMMIT_SHA"
