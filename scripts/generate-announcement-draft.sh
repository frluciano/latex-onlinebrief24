#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  printf '%s\n' "Usage: sh scripts/generate-announcement-draft.sh <output-path>" >&2
  exit 1
fi

output_path=$1
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
release_pattern='[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]'
manual_announcement_path="$repo_root/ctan/release-announcement.txt"

if [ -f "$manual_announcement_path" ]; then
  manual_trimmed=$(
    python3 - "$manual_announcement_path" <<'PY'
import sys
from pathlib import Path

print(Path(sys.argv[1]).read_text(encoding="utf-8").strip())
PY
  )
  if [ -z "$manual_trimmed" ]; then
    printf '%s\n' "Manual CTAN announcement fragment is empty: $manual_announcement_path" >&2
    exit 1
  fi

  mkdir -p "$(dirname "$output_path")"
  cp "$manual_announcement_path" "$output_path"
  printf '%s\n' "CTAN announcement draft: $output_path"
  printf '%s\n' "Announcement source: manual fragment $manual_announcement_path"
  exit 0
fi

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

# Keep the draft deterministic and human-readable. The prepare workflow may use
# a manually curated release fragment when present; otherwise it derives a
# filtered bullet list from commit subjects. The release workflow may reject the
# draft, but it must never invent fallback announcement text on its own.
commit_lines=$(
  python3 - "$repo_root" "$range_spec" <<'PY'
import re
import subprocess
import sys

repo_root = sys.argv[1]
range_spec = sys.argv[2]
subjects = subprocess.check_output(
    ["git", "-C", repo_root, "log", "--reverse", "--format=%s", range_spec],
    text=True,
).splitlines()

skip_pattern = re.compile(
    r"^(merge( branch| pull request)?|chore|ci|docs?|test|tests|build|style|release)(\(.+\))?!?:\s*",
    re.IGNORECASE,
)
strip_prefix_pattern = re.compile(
    r"^(feat|fix|refactor|perf)(\(.+\))?!?:\s*",
    re.IGNORECASE,
)

lines = []
for subject in subjects:
    subject = subject.strip()
    if not subject:
        continue
    if skip_pattern.match(subject):
        continue
    subject = strip_prefix_pattern.sub("", subject, count=1).strip()
    if not subject:
        continue
    lines.append(f"- {subject}")

print("\n".join(lines))
PY
)

if [ -z "$commit_lines" ]; then
  printf '%s\n' "No releasable commit messages found for the CTAN announcement draft. Add ctan/release-announcement.txt for a manual announcement." >&2
  exit 1
fi

mkdir -p "$(dirname "$output_path")"
{
  printf '%s\n\n' "$heading"
  printf '%s\n' "$commit_lines"
} > "$output_path"

printf '%s\n' "CTAN announcement draft: $output_path"
printf '%s\n' "Announcement source: filtered commit subjects"
if [ -n "$last_release_tag" ]; then
  printf '%s\n' "Last release tag: $last_release_tag"
else
  printf '%s\n' "Last release tag: none"
fi
