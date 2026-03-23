#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/lib/common.sh"

repo_root=$(repo_root_from_dir "$script_dir")
cd "$repo_root"

# Catch shell syntax errors before release or CI logic changes land on main.
# shellcheck disable=SC2044
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

# Release validation and workflow-summary helpers live in Python. Compile them
# ahead of time so CI catches syntax errors before GitHub Actions executes them.
# shellcheck disable=SC2046
PYTHONPYCACHEPREFIX="${TMPDIR:-/tmp}/ob24-pycache" \
  python3 -m py_compile $(find scripts -type f -name '*.py' | sort)

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

# Static analysis for all shell scripts. shellcheck is pre-installed on
# ubuntu-latest and available in most developer environments via the system
# package manager.  Use --shell=sh because all scripts target POSIX sh.
if command -v shellcheck >/dev/null 2>&1; then
  # shellcheck disable=SC2044
  for script in $(find scripts -type f -name '*.sh' | sort); do
    # SC1007: CDPATH= idiom is valid POSIX sh; not a broken assignment.
    # SC1091: lib/common.sh is sourced via $script_dir which shellcheck cannot
    #         statically resolve; the path is always correct at runtime.
    shellcheck --shell=sh --exclude=SC1007,SC1091 "$script"
  done
else
  printf '%s\n' "Warning: shellcheck not found; skipping static analysis." >&2
fi

printf '%s\n' "Tooling checks passed."
