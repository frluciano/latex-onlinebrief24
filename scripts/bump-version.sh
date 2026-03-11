#!/bin/sh
set -eu

# Usage: sh scripts/bump-version.sh [YYYY-MM-DD]
# Example: sh scripts/bump-version.sh 2026-04-15
#
# Updates the date in \ProvidesClass inside onlinebrief24.cls and
# the date in ctan/onlinebrief24-doc.tex.
# If no date is given, uses today's date.

date=${1:-$(date +%Y-%m-%d)}

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cls_file="$repo_root/onlinebrief24.cls"
doc_file="$repo_root/ctan/onlinebrief24-doc.tex"

# Validate date format (YYYY-MM-DD)
if ! printf '%s' "$date" | grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2}$'; then
  printf '%s\n' "Error: date must be in YYYY-MM-DD format (got: $date)" >&2
  exit 1
fi

# Convert to LaTeX format (YYYY/MM/DD) for \ProvidesClass
cls_date=$(printf '%s' "$date" | tr '-' '/')

# Update \ProvidesClass date
sed -i.bak "s|\\\\ProvidesClass{onlinebrief24}\[.*\]|\\\\ProvidesClass{onlinebrief24}[$cls_date Precision Layout Class with Guides]|" "$cls_file"
rm -f "$cls_file.bak"

# Update documentation date
sed -i.bak "s|\\\\date{[0-9-]*}|\\\\date{$date}|" "$doc_file"
rm -f "$doc_file.bak"

printf '%s\n' "Updated onlinebrief24.cls and onlinebrief24-doc.tex to $date"
