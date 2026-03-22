#!/bin/sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  printf '%s\n' "Usage: sh scripts/release-ctan.sh <bundle-dir> [expected-prepare-run-id]" >&2
  exit 1
fi

bundle_dir=$1
expected_prepare_run_id=${2:-}
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
metadata_path="$bundle_dir/release-metadata.json"

if [ -z "${CTAN_EMAIL:-}" ]; then
  printf '%s\n' "CTAN_EMAIL is required in the release context. Refusing to publish." >&2
  exit 1
fi

ctan_o_mat_bin=${CTAN_O_MAT_BIN:-/usr/local/bin/ctan-o-mat}
if [ ! -f "$ctan_o_mat_bin" ]; then
  printf '%s\n' "ctan-o-mat executable not found at $ctan_o_mat_bin" >&2
  exit 1
fi

# Re-run the bundle validation in the publish context so approval cannot bypass
# any prepare-time guarantees.
sh "$repo_root/scripts/validate-release-inputs.sh" "$bundle_dir" "$expected_prepare_run_id"

metadata_values=$(
  python3 - "$metadata_path" <<'PY'
import json
import sys
from pathlib import Path

# Re-read the canonical values from metadata after validation instead of trying
# to reconstruct them from file names or workflow inputs.
metadata = json.loads(Path(sys.argv[1]).read_text(encoding="utf-8"))
print(f"ARTIFACT_FILENAME={metadata['artifact_filename']}")
print(f"ANNOUNCEMENT_FILENAME={metadata['announcement_filename']}")
print(f"PREPARE_RUN_ID={metadata['prepare_run_id']}")
print(f"SOURCE_COMMIT_SHA={metadata['source_commit_sha']}")
print(f"VERSION={metadata['version']}")
PY
)

eval "$metadata_values"

artifact_path="$bundle_dir/$ARTIFACT_FILENAME"
announcement_path="$bundle_dir/$ANNOUNCEMENT_FILENAME"
rendered_pkg="$bundle_dir/onlinebrief24-release.pkg"

# Render the ctan-o-mat input from the frozen bundle contents instead of any
# mutable workspace state.
python3 - "$repo_root/ctan/onlinebrief24.pkg" "$rendered_pkg" "$announcement_path" "$artifact_path" "$VERSION" <<'PY'
import os
import sys
from pathlib import Path

template_path = Path(sys.argv[1])
output_path = Path(sys.argv[2])
announcement_path = Path(sys.argv[3])
artifact_path = sys.argv[4]
version = sys.argv[5]
ctan_email = os.environ["CTAN_EMAIL"]

announcement = announcement_path.read_text(encoding="utf-8").strip()
if not announcement:
    raise SystemExit("Announcement draft must not be empty.")

content = template_path.read_text(encoding="utf-8")
content = content.replace("${VERSION}", version)
content = content.replace("${CTAN_EMAIL}", ctan_email)
content = content.replace("${CTAN_ZIP}", artifact_path)
content = content.replace("${ANNOUNCEMENT}", announcement)
output_path.write_text(content, encoding="utf-8")
PY

# Log the publication mapping explicitly so the CTAN submit can always be traced
# back to the prepare run and commit that produced the artifact.
printf '%s\n' "Publishing prepared CTAN artifact"
printf '%s\n' "Prepare run ID: $PREPARE_RUN_ID"
printf '%s\n' "Prepared commit: $SOURCE_COMMIT_SHA"
printf '%s\n' "Prepared version: $VERSION"
printf '%s\n' "Prepared artifact: $ARTIFACT_FILENAME"

perl "$ctan_o_mat_bin" --validate "$rendered_pkg"
perl "$ctan_o_mat_bin" --submit "$rendered_pkg"
