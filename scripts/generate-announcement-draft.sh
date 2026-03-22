#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  printf '%s\n' "Usage: sh scripts/generate-announcement-draft.sh <output-path>" >&2
  exit 1
fi

output_path=$1
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
release_pattern='[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'

# Use the newest release-like tag as the announcement boundary. If none exists,
# the draft falls back to the full reachable history.
last_release_tag=$(
  git -C "$repo_root" tag --merged HEAD --list "$release_pattern" --sort=-creatordate | head -n 1
)

if [ -n "$last_release_tag" ]; then
  range_spec="${last_release_tag}..HEAD"
  heading="Changes since ${last_release_tag}:"
else
  range_spec="HEAD"
  heading="Changes included in this release:"
fi

# Keep the draft deterministic and human-readable: oldest-to-newest order and
# commit subjects only. The release workflow may reject the draft, but it must
# never invent fallback announcement text on its own.
commit_lines=$(git -C "$repo_root" log --reverse --format='- %s' "$range_spec")
if [ -z "$commit_lines" ]; then
  printf '%s\n' "No commit messages found for the CTAN announcement draft." >&2
  exit 1
fi

mkdir -p "$(dirname "$output_path")"
{
  printf '%s\n\n' "$heading"
  printf '%s\n' "$commit_lines"
} > "$output_path"

printf '%s\n' "CTAN announcement draft: $output_path"
if [ -n "$last_release_tag" ]; then
  printf '%s\n' "Last release tag: $last_release_tag"
else
  printf '%s\n' "Last release tag: none"
fi
