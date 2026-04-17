#!/bin/sh
set -eu

if [ "$#" -ne 3 ]; then
	printf '%s\n' "Usage: sh scripts/generate-release-metadata.sh <artifact-zip> <announcement-draft> <output-path>" >&2
	exit 1
fi

artifact_path=$1
announcement_path=$2
output_path=$3
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/lib/common.sh"

repo_root=$(repo_root_from_dir "$script_dir")

require_file "$artifact_path" "Artifact ZIP not found: $artifact_path"
require_file "$announcement_path" "Announcement draft not found: $announcement_path"

artifact_filename=$(basename "$artifact_path")
announcement_filename=$(basename "$announcement_path")
# The artifact name already encodes the public CTAN version. Derive the version
# from that immutable file name instead of trusting a second source of truth.
version=$(printf '%s\n' "$artifact_filename" | sed -n 's/^onlinebrief24-\(.*\)\.zip$/\1/p')

if [ -z "$version" ]; then
	printf '%s\n' "Could not derive version from artifact filename: $artifact_filename" >&2
	exit 1
fi

artifact_sha256=$(python3 -c \
  "import hashlib,sys; print(hashlib.sha256(open(sys.argv[1],'rb').read()).hexdigest())" \
  "$artifact_path")
source_commit_sha=$(git -C "$repo_root" rev-parse HEAD)
# Local/manual preparation still needs stable positive identifiers so the same
# validation rules work in CI and outside GitHub Actions.
prepare_run_id=${PREPARE_RUN_ID:-${GITHUB_RUN_ID:-$(date -u +%s)}}
prepare_run_attempt=${PREPARE_RUN_ATTEMPT:-${GITHUB_RUN_ATTEMPT:-1}}
build_timestamp_utc=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Validate that the fields we embed unquoted in JSON are safe integer values.
case "$prepare_run_id" in
  *[!0-9]*|'') printf '%s\n' "error: prepare_run_id is not a non-empty integer: '$prepare_run_id'" >&2; exit 1 ;;
esac
case "$prepare_run_attempt" in
  *[!0-9]*|'') printf '%s\n' "error: prepare_run_attempt is not a non-empty integer: '$prepare_run_attempt'" >&2; exit 1 ;;
esac
# Validate version so a malformed artifact filename cannot produce bad JSON.
case "$version" in
  [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]) ;;
  *) printf '%s\n' "error: version does not match YYYY-MM-DD: '$version'" >&2; exit 1 ;;
esac
version_month=$(printf '%s' "$version" | cut -c6-7)
version_day=$(printf '%s' "$version" | cut -c9-10)
case "$version_month" in
  01|02|03|04|05|06|07|08|09|10|11|12) ;;
  *) printf '%s\n' "error: version month out of range (01-12): '$version'" >&2; exit 1 ;;
esac
case "$version_day" in
  0[1-9]|[12][0-9]|3[01]) ;;
  *) printf '%s\n' "error: version day out of range (01-31): '$version'" >&2; exit 1 ;;
esac

mkdir -p "$(dirname "$output_path")"
# Keep the contract deliberately small. Anything not required for provenance or
# publish-time validation stays out of the schema to reduce drift.
cat >"$output_path" <<EOF
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
