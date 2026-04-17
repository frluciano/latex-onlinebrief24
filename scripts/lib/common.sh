#!/bin/sh
set -eu

fail() {
  printf '%s\n' "$1" >&2
  exit 1
}

repo_root_from_dir() {
  CDPATH= cd -- "$1/.." && pwd
}

require_dir() {
  if [ ! -d "$1" ]; then
    fail "$2"
  fi
}

require_file() {
  if [ ! -f "$1" ]; then
    fail "$2"
  fi
}

require_env() {
  var_name=$1
  message=$2
  eval "value=\${$var_name:-}"

  if [ -z "$value" ]; then
    fail "$message"
  fi
}

# Normalize GH_TOKEN / GITHUB_TOKEN: export GH_TOKEN if not already set.
normalize_gh_token() {
  if [ -z "${GH_TOKEN:-}" ] && [ -n "${GITHUB_TOKEN:-}" ]; then
    GH_TOKEN=$GITHUB_TOKEN
    export GH_TOKEN
  fi
}

# Extract the YYYY-MM-DD version string from the \ProvidesClass line in onlinebrief24.cls.
# Usage: version=$(read_cls_version path/to/onlinebrief24.cls)
read_cls_version() {
  sed -n 's/.*\\ProvidesClass{onlinebrief24}\[\([0-9/]*\).*/\1/p' "$1" | tr '/' '-'
}
