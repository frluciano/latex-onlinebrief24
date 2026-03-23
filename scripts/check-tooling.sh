#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

# Catch shell syntax errors before release or CI logic changes land on main.
for script in scripts/*.sh; do
  sh -n "$script"
done

# Keep workflow YAML parseable even when expressions or block scalars change.
ruby - <<'RUBY'
require "yaml"

Dir.glob(".github/workflows/*.yml").sort.each do |path|
  YAML.load_file(path)
end
RUBY

# The release template must keep the placeholders that the publish script
# injects at submit time.
python3 - <<'PY'
from pathlib import Path

template = Path("ctan/onlinebrief24.pkg").read_text(encoding="utf-8")
required = (
    "${VERSION}",
    "${CTAN_EMAIL}",
    "${CTAN_ZIP}",
    "${ANNOUNCEMENT}",
)
missing = [token for token in required if token not in template]
if missing:
    raise SystemExit(
        "ctan/onlinebrief24.pkg is missing required placeholders: "
        + ", ".join(missing)
    )
PY

printf '%s\n' "Tooling checks passed."
