#!/bin/sh
set -eu

# Usage: sh scripts/bump-version.sh <version> [date]
# Example: sh scripts/bump-version.sh 1.1.0
# Example: sh scripts/bump-version.sh 1.1.0 2026/04/15
#
# Updates the version and date in \ProvidesClass inside onlinebrief24.cls.
# If no date is given, uses today's date in YYYY/MM/DD format.

if [ $# -lt 1 ]; then
  printf '%s\n' "Usage: $0 <version> [YYYY/MM/DD]" >&2
  exit 1
fi

version=$1
date=${2:-$(date +%Y/%m/%d)}

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cls_file="$repo_root/onlinebrief24.cls"

# Validate version format (semver without leading v)
if ! printf '%s' "$version" | grep -qE '^[0-9]+\.[0-9]+\.[0-9]+$'; then
  printf '%s\n' "Error: version must be in X.Y.Z format (got: $version)" >&2
  exit 1
fi

# Validate date format
if ! printf '%s' "$date" | grep -qE '^[0-9]{4}/[0-9]{2}/[0-9]{2}$'; then
  printf '%s\n' "Error: date must be in YYYY/MM/DD format (got: $date)" >&2
  exit 1
fi

# Replace the ProvidesClass line
sed -i.bak "s|\\\\ProvidesClass{onlinebrief24}\[.*\]|\\\\ProvidesClass{onlinebrief24}[$date v$version Precision Layout Class with Guides]|" "$cls_file"
rm -f "$cls_file.bak"

printf '%s\n' "Updated onlinebrief24.cls to v$version ($date)"
