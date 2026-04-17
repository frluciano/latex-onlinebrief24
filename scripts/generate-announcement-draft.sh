#!/bin/sh
set -eu

if [ "$#" -ne 1 ]; then
  printf '%s\n' "Usage: sh scripts/generate-announcement-draft.sh <output-path>" >&2
  exit 1
fi

output_path=$1
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/lib/common.sh"

scripts_lib="$script_dir/lib"

repo_root=$(repo_root_from_dir "$script_dir")
manual_announcement_path="$repo_root/ctan/release-announcement.txt"

require_file "$manual_announcement_path" "Manual CTAN announcement file not found: $manual_announcement_path
Create ctan/release-announcement.txt explicitly before running Prepare CTAN Release."

manual_trimmed=$(python3 "$scripts_lib/release_validation.py" read-announcement "$manual_announcement_path")

if [ -z "$manual_trimmed" ]; then
  fail "Manual CTAN announcement file is empty: $manual_announcement_path"
fi

mkdir -p "$(dirname "$output_path")"
cp "$manual_announcement_path" "$output_path"

printf '%s\n' "CTAN announcement draft: $output_path"
printf '%s\n' "Announcement source: manual fragment $manual_announcement_path"
