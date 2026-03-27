#!/bin/sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  printf '%s\n' "Usage: sh scripts/sync-github-release.sh <bundle-dir> [expected-release-run-id]" >&2
  exit 1
fi

bundle_dir=$1
expected_release_run_id=${2:-}
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/lib/common.sh"

repo_root=$(repo_root_from_dir "$script_dir")
metadata_path="$bundle_dir/release-metadata.json"
resolved_metadata_path="$bundle_dir/resolved-release-metadata.json"

if [ -z "${GH_TOKEN:-}" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
  GH_TOKEN=$GITHUB_TOKEN
  export GH_TOKEN
fi

require_env GH_TOKEN "GH_TOKEN or GITHUB_TOKEN is required to create the GitHub release."
require_env GITHUB_REPOSITORY "GITHUB_REPOSITORY is required in the GitHub release sync context."
require_file "$resolved_metadata_path" "Resolved release metadata not found: $resolved_metadata_path"

# Reuse the existing CTAN bundle validation so the GitHub release is built from
# exactly the same checked inputs that were accepted for CTAN publication.
sh "$repo_root/scripts/validate-release-inputs.sh" "$bundle_dir"

# Validate that the resolved metadata still matches the frozen prepare bundle
# and belongs to the specific successful CTAN release run we are syncing from.
metadata_values=$(
  python3 - "$metadata_path" "$resolved_metadata_path" "$expected_release_run_id" <<'PY'
import json
import re
import sys
from pathlib import Path

metadata = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
resolved = json.loads(Path(sys.argv[2]).read_text(encoding="utf-8"))
expected_release_run_id = sys.argv[3]

shared_fields = (
    "schema_version",
    "package_name",
    "version",
    "artifact_filename",
    "artifact_sha256",
    "source_commit_sha",
    "prepare_run_id",
    "prepare_run_attempt",
    "build_timestamp_utc",
    "announcement_filename",
)
for key in shared_fields:
    if resolved.get(key) != metadata.get(key):
        raise SystemExit(
            f"resolved-release-metadata field {key!r} does not match release-metadata.json"
        )

release_run_id = str(resolved.get("release_run_id", ""))
release_run_attempt = str(resolved.get("release_run_attempt", ""))
release_requested_by = str(resolved.get("release_requested_by", ""))
release_timestamp_utc = str(resolved.get("release_timestamp_utc", ""))

if not re.fullmatch(r"[0-9]+", release_run_id):
    raise SystemExit("release_run_id in resolved-release-metadata.json must be a positive integer string")

if not re.fullmatch(r"[0-9]+", release_run_attempt):
    raise SystemExit("release_run_attempt in resolved-release-metadata.json must be a positive integer string")

if not re.fullmatch(r"[A-Za-z0-9-]+", release_requested_by):
    raise SystemExit("release_requested_by must look like a GitHub login")

if not re.fullmatch(r"[0-9]{4}-[0-9]{2}-[0-9]{2}T[0-9]{2}:[0-9]{2}:[0-9]{2}Z", release_timestamp_utc):
    raise SystemExit("release_timestamp_utc must use an ISO-8601 UTC timestamp")

if expected_release_run_id and release_run_id != expected_release_run_id:
    raise SystemExit(
        f"resolved-release-metadata release_run_id {release_run_id} does not match expected release run ID {expected_release_run_id}"
    )

print(f"ANNOUNCEMENT_FILENAME={metadata['announcement_filename']}")
print(f"ARTIFACT_FILENAME={metadata['artifact_filename']}")
print(f"PREPARE_RUN_ID={metadata['prepare_run_id']}")
print(f"RELEASE_RUN_ID={release_run_id}")
print(f"RELEASE_RUN_ATTEMPT={release_run_attempt}")
print(f"SOURCE_COMMIT_SHA={metadata['source_commit_sha']}")
print(f"VERSION={metadata['version']}")
PY
)

eval "$metadata_values"

artifact_path="$bundle_dir/$ARTIFACT_FILENAME"
checksum_path="$artifact_path.sha256"
announcement_path="$bundle_dir/$ANNOUNCEMENT_FILENAME"
tag_name="$VERSION"
release_title="onlinebrief24 $VERSION"

if ! git -C "$repo_root" rev-parse --verify "${SOURCE_COMMIT_SHA}^{commit}" >/dev/null 2>&1; then
  printf '%s\n' "Prepared source commit is not available locally: $SOURCE_COMMIT_SHA" >&2
  exit 1
fi

remote_tag_commit_sha=$(
  python3 - "$GITHUB_REPOSITORY" "$tag_name" <<'PY'
import json
import subprocess
import sys

repo = sys.argv[1]
tag_name = sys.argv[2]

proc = subprocess.run(
    ["gh", "api", f"repos/{repo}/git/ref/tags/{tag_name}"],
    text=True,
    capture_output=True,
)
if proc.returncode != 0:
    stderr = proc.stderr or ""
    if "404" in stderr or "Not Found" in stderr:
        print("")
        raise SystemExit(0)
    raise SystemExit(stderr.strip() or f"Failed to query tag {tag_name}")

ref_data = json.loads(proc.stdout)
obj = ref_data["object"]
if obj["type"] == "commit":
    print(obj["sha"])
    raise SystemExit(0)

if obj["type"] != "tag":
    raise SystemExit(f"Unsupported remote tag object type: {obj['type']}")

tag_data = json.loads(
    subprocess.check_output(
        ["gh", "api", f"repos/{repo}/git/tags/{obj['sha']}"],
        text=True,
    )
)
target = tag_data["object"]
if target["type"] != "commit":
    raise SystemExit(f"Annotated tag {tag_name} does not point to a commit.")
print(target["sha"])
PY
)

if [ -n "$remote_tag_commit_sha" ] && [ "$remote_tag_commit_sha" != "$SOURCE_COMMIT_SHA" ]; then
  printf '%s\n' "Remote tag $tag_name points to $remote_tag_commit_sha, expected $SOURCE_COMMIT_SHA." >&2
  exit 1
fi

printf '%s\n' "Syncing GitHub release from validated CTAN bundle"
printf '%s\n' "Release run ID: $RELEASE_RUN_ID"
printf '%s\n' "Release run attempt: $RELEASE_RUN_ATTEMPT"
printf '%s\n' "Prepare run ID: $PREPARE_RUN_ID"
printf '%s\n' "Prepared commit: $SOURCE_COMMIT_SHA"
printf '%s\n' "Prepared version: $VERSION"
printf '%s\n' "Prepared artifact: $ARTIFACT_FILENAME"

if gh release view "$tag_name" --repo "$GITHUB_REPOSITORY" >/dev/null 2>&1; then
  # Keep retries idempotent: update the existing release body and replace the
  # release assets instead of creating a second GitHub release.
  gh release edit "$tag_name" \
    --repo "$GITHUB_REPOSITORY" \
    --title "$release_title" \
    --notes-file "$announcement_path" \
    --verify-tag
  # `--clobber` replaces assets in place. If an upload fails, rerun this
  # workflow with the same release run ID instead of touching CTAN again.
  gh release upload "$tag_name" \
    --repo "$GITHUB_REPOSITORY" \
    --clobber \
    "$artifact_path" \
    "$checksum_path" \
    "$announcement_path" \
    "$metadata_path" \
    "$resolved_metadata_path"
else
  if [ -n "$remote_tag_commit_sha" ]; then
    gh release create "$tag_name" \
      --repo "$GITHUB_REPOSITORY" \
      --title "$release_title" \
      --notes-file "$announcement_path" \
      --verify-tag \
      "$artifact_path" \
      "$checksum_path" \
      "$announcement_path" \
      "$metadata_path" \
      "$resolved_metadata_path"
  else
    # Let `gh release create` create the missing tag at the validated commit
    # instead of posting the git ref separately. This keeps the first publish
    # path compatible with GitHub's workflow token restrictions.
    gh release create "$tag_name" \
      --repo "$GITHUB_REPOSITORY" \
      --target "$SOURCE_COMMIT_SHA" \
      --title "$release_title" \
      --notes-file "$announcement_path" \
      "$artifact_path" \
      "$checksum_path" \
      "$announcement_path" \
      "$metadata_path" \
      "$resolved_metadata_path"
  fi
fi
