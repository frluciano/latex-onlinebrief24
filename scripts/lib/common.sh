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
