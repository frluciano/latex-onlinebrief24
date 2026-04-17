#!/bin/sh
set -eu

# Usage: sh scripts/bump-version.sh [YYYY-MM-DD]
# Example: sh scripts/bump-version.sh 2026-04-15
#
# Updates the date in \ProvidesClass inside onlinebrief24.cls and
# the date in ctan/onlinebrief24-doc.tex.
# If no date is given, uses today's date.

date=${1:-$(date +%Y-%m-%d)}

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/lib/common.sh"

repo_root=$(repo_root_from_dir "$script_dir")
cls_file="$repo_root/onlinebrief24.cls"
doc_file="$repo_root/ctan/onlinebrief24-doc.tex"

# Validate date format (YYYY-MM-DD)
if ! printf '%s' "$date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
  printf '%s\n' "error: date must be in YYYY-MM-DD format (got: $date)" >&2
  exit 1
fi

# Validate month (01-12) and day (01-31) ranges.
month=$(printf '%s' "$date" | cut -c6-7)
day=$(printf '%s' "$date" | cut -c9-10)
case "$month" in
  01|02|03|04|05|06|07|08|09|10|11|12) ;;
  *) printf '%s\n' "error: month out of range (01-12): $month" >&2; exit 1 ;;
esac
case "$day" in
  0[1-9]|[12][0-9]|3[01]) ;;
  *) printf '%s\n' "error: day out of range (01-31): $day" >&2; exit 1 ;;
esac

# Convert to LaTeX format (YYYY/MM/DD) for \ProvidesClass
cls_date=$(printf '%s' "$date" | tr '-' '/')

# Ensure any temp file is removed if the script exits early.
tmp=
trap 'rm -f "$tmp"' EXIT

# Update \ProvidesClass date — portable temp-file approach (avoids GNU/BSD sed -i differences).
# cat redirection writes to the original inode, preserving file permissions.
tmp=$(mktemp)
sed "s|\\\\ProvidesClass{onlinebrief24}\[.*\]|\\\\ProvidesClass{onlinebrief24}[$cls_date Precision Layout Class with Guides]|" \
  "$cls_file" > "$tmp" && cat "$tmp" > "$cls_file"
rm -f "$tmp"

# Update documentation date
tmp=$(mktemp)
sed "s|\\\\date{[0-9-]*}|\\\\date{$date}|" "$doc_file" > "$tmp" && cat "$tmp" > "$doc_file"

printf '%s\n' "Updated onlinebrief24.cls and onlinebrief24-doc.tex to $date"
