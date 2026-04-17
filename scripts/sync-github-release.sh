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

scripts_lib="$script_dir/lib"
repo_root=$(repo_root_from_dir "$script_dir")
metadata_path="$bundle_dir/release-metadata.json"
resolved_metadata_path="$bundle_dir/resolved-release-metadata.json"

normalize_gh_token
require_env GH_TOKEN "GH_TOKEN or GITHUB_TOKEN is required to create the GitHub release."
require_env GITHUB_REPOSITORY "GITHUB_REPOSITORY is required in the GitHub release sync context."
require_file "$resolved_metadata_path" "Resolved release metadata not found: $resolved_metadata_path"

# Reuse the existing CTAN bundle validation so the GitHub release is built from
# exactly the same checked inputs that were accepted for CTAN publication.
sh "$repo_root/scripts/validate-release-inputs.sh" "$bundle_dir"

# Validate that the resolved metadata still matches the frozen prepare bundle
# and belongs to the specific successful CTAN release run we are syncing from.
python3 "$scripts_lib/release_workflow.py" validate-resolved-release-metadata \
  "$bundle_dir" "$expected_release_run_id"

# Extract each field individually — no eval, no injection risk.
ANNOUNCEMENT_FILENAME=$(python3 "$scripts_lib/release_validation.py" get-field "$metadata_path" announcement_filename)
ARTIFACT_FILENAME=$(python3 "$scripts_lib/release_validation.py" get-field "$metadata_path" artifact_filename)
PREPARE_RUN_ID=$(python3 "$scripts_lib/release_validation.py" get-field "$metadata_path" prepare_run_id)
RELEASE_RUN_ID=$(python3 "$scripts_lib/release_validation.py" get-field "$resolved_metadata_path" release_run_id)
RELEASE_RUN_ATTEMPT=$(python3 "$scripts_lib/release_validation.py" get-field "$resolved_metadata_path" release_run_attempt)
SOURCE_COMMIT_SHA=$(python3 "$scripts_lib/release_validation.py" get-field "$metadata_path" source_commit_sha)
VERSION=$(python3 "$scripts_lib/release_validation.py" get-field "$metadata_path" version)

artifact_path="$bundle_dir/$ARTIFACT_FILENAME"
checksum_path="$artifact_path.sha256"
announcement_path="$bundle_dir/$ANNOUNCEMENT_FILENAME"
tag_name="$VERSION"
release_title="onlinebrief24 $VERSION"

if ! git -C "$repo_root" rev-parse --verify "${SOURCE_COMMIT_SHA}^{commit}" >/dev/null 2>&1; then
  printf '%s\n' "Prepared source commit is not available locally: $SOURCE_COMMIT_SHA" >&2
  exit 1
fi

remote_tag_refs=$(
  git -C "$repo_root" ls-remote --tags origin \
    "refs/tags/${tag_name}" \
    "refs/tags/${tag_name}^{}"
)
remote_tag_commit_sha=$(
  printf '%s\n' "$remote_tag_refs" | awk -v ref="refs/tags/$tag_name" '
    $2 == ref "^{}" { deref = $1 }
    $2 == ref { direct = $1 }
    END {
      if (deref != "") {
        print deref
      } else if (direct != "") {
        print direct
      }
    }
  '
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
