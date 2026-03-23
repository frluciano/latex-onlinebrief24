#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/lib/common.sh"

repo_root=$(repo_root_from_dir "$script_dir")
cd "$repo_root"

# Catch shell syntax errors before release or CI logic changes land on main.
for script in $(find scripts -type f -name '*.sh' | sort); do
  first_line=$(sed -n '1p' "$script")
  second_line=$(sed -n '2p' "$script")

  if [ "$first_line" != '#!/bin/sh' ]; then
    fail "$script must start with #!/bin/sh"
  fi

  if [ "$second_line" != 'set -eu' ]; then
    fail "$script must enable set -eu on line 2"
  fi

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
