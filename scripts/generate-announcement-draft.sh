#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  printf '%s\n' "Usage: sh scripts/generate-announcement-draft.sh <output-path>" >&2
  exit 1
fi

output_path=$1
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
manual_announcement_path="$repo_root/ctan/release-announcement.txt"

if [ ! -f "$manual_announcement_path" ]; then
  printf '%s\n' "Manual CTAN announcement file not found: $manual_announcement_path" >&2
  printf '%s\n' "Create ctan/release-announcement.txt explicitly before running Prepare CTAN Release." >&2
  exit 1
fi

manual_trimmed=$(
  python3 - "$manual_announcement_path" <<'PY'
import sys
from pathlib import Path

print(Path(sys.argv[1]).read_text(encoding="utf-8").strip())
PY
)

if [ -z "$manual_trimmed" ]; then
  printf '%s\n' "Manual CTAN announcement file is empty: $manual_announcement_path" >&2
  exit 1
fi

mkdir -p "$(dirname "$output_path")"
cp "$manual_announcement_path" "$output_path"

printf '%s\n' "CTAN announcement draft: $output_path"
printf '%s\n' "Announcement source: manual fragment $manual_announcement_path"
