#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
  printf '%s\n' "Usage: sh scripts/generate-release-metadata.sh <artifact-zip> <announcement-draft> <output-path>" >&2
  exit 1
fi

artifact_path=$1
announcement_path=$2
output_path=$3
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)

if [ ! -f "$artifact_path" ]; then
  printf '%s\n' "Artifact ZIP not found: $artifact_path" >&2
  exit 1
fi

if [ ! -f "$announcement_path" ]; then
  printf '%s\n' "Announcement draft not found: $announcement_path" >&2
  exit 1
fi

artifact_filename=$(basename "$artifact_path")
announcement_filename=$(basename "$announcement_path")
# The artifact name already encodes the public CTAN version. Derive the version
# from that immutable file name instead of trusting a second source of truth.
version=$(printf '%s\n' "$artifact_filename" | sed -n 's/^onlinebrief24-\(.*\)\.zip$/\1/p')

if [ -z "$version" ]; then
  printf '%s\n' "Could not derive version from artifact filename: $artifact_filename" >&2
  exit 1
fi

artifact_sha256=$(sha256sum "$artifact_path" | awk '{print $1}')
source_commit_sha=$(git -C "$repo_root" rev-parse HEAD)
# Local/manual preparation still needs stable positive identifiers so the same
# validation rules work in CI and outside GitHub Actions.
prepare_run_id=${PREPARE_RUN_ID:-${GITHUB_RUN_ID:-$(date -u +%s)}}
prepare_run_attempt=${PREPARE_RUN_ATTEMPT:-${GITHUB_RUN_ATTEMPT:-1}}
build_timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

mkdir -p "$(dirname "$output_path")"
# Keep the contract deliberately small. Anything not required for provenance or
# publish-time validation stays out of the schema to reduce drift.
cat > "$output_path" <<EOF
{
  "schema_version": 1,
  "package_name": "onlinebrief24",
  "version": "$version",
  "artifact_filename": "$artifact_filename",
  "artifact_sha256": "$artifact_sha256",
  "source_commit_sha": "$source_commit_sha",
  "prepare_run_id": $prepare_run_id,
  "prepare_run_attempt": $prepare_run_attempt,
  "build_timestamp_utc": "$build_timestamp_utc",
  "announcement_filename": "$announcement_filename"
}
EOF

printf '%s\n' "Release metadata: $output_path"
