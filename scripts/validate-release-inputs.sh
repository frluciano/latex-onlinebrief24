#!/bin/sh
set -eu

if [ "$#" -lt 1 ] || [ "$#" -gt 2 ]; then
  printf '%s\n' "Usage: sh scripts/validate-release-inputs.sh <bundle-dir> [expected-prepare-run-id]" >&2
  exit 1
fi

bundle_dir=$1
expected_prepare_run_id=${2:-}
script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/lib/common.sh"

repo_root=$(repo_root_from_dir "$script_dir")
metadata_path="$bundle_dir/release-metadata.json"

require_dir "$bundle_dir" "Prepared release bundle directory not found: $bundle_dir"
require_file "$metadata_path" "Prepared release metadata not found: $metadata_path"

# Parse and validate the JSON contract in Python so the shell only deals with
# already-normalized scalar values.
metadata_values=$(
  python3 - "$metadata_path" <<'PY'
import json
import re
import sys
from pathlib import Path

metadata_path = Path(sys.argv[1])
data = json.loads(metadata_path.read_text(encoding="utf-8"))
required = (
    "schema_version",
    "package_name",
    "version",
    "artifact_filename",
    "artifact_sha256",
    "source_commit_sha",
    "prepare_run_id",
    "prepare_run_attempt",
    "build_timestamp_utc",
    "announcement_filename",
)
missing = [key for key in required if key not in data or data[key] in ("", None)]
if missing:
    raise SystemExit(
        f"Missing required metadata fields in {metadata_path}: {', '.join(missing)}"
    )

if data["schema_version"] != 1:
    raise SystemExit(f"Unsupported metadata schema_version: {data['schema_version']}")

if data["package_name"] != "onlinebrief24":
    raise SystemExit(f"Unexpected package_name: {data['package_name']}")

if not re.fullmatch(r"[0-9]{4}-[0-9]{2}-[0-9]{2}", data["version"]):
    raise SystemExit(f"Version must use YYYY-MM-DD: {data['version']}")

if data["artifact_filename"] != f"onlinebrief24-{data['version']}.zip":
    raise SystemExit(
        "Artifact filename does not match package name and version: "
        f"{data['artifact_filename']}"
    )

if not re.fullmatch(r"[0-9a-f]{64}", data["artifact_sha256"]):
    raise SystemExit("artifact_sha256 must be a lowercase SHA-256 hex digest")

if not re.fullmatch(r"[0-9a-f]{40}", data["source_commit_sha"]):
    raise SystemExit("source_commit_sha must be a full 40-character Git commit SHA")

# Restrict the announcement path to a simple file name so metadata cannot point
# outside the prepared release bundle.
if not re.fullmatch(r"[A-Za-z0-9._-]+", data["announcement_filename"]):
    raise SystemExit("announcement_filename must be a simple file name")

if not isinstance(data["prepare_run_id"], int) or data["prepare_run_id"] <= 0:
    raise SystemExit("prepare_run_id must be a positive integer")

if not isinstance(data["prepare_run_attempt"], int) or data["prepare_run_attempt"] <= 0:
    raise SystemExit("prepare_run_attempt must be a positive integer")

print(f"ARTIFACT_FILENAME={data['artifact_filename']}")
print(f"ARTIFACT_SHA256={data['artifact_sha256']}")
print(f"ANNOUNCEMENT_FILENAME={data['announcement_filename']}")
print(f"SOURCE_COMMIT_SHA={data['source_commit_sha']}")
print(f"PREPARE_RUN_ID={data['prepare_run_id']}")
print(f"VERSION={data['version']}")
PY
)

eval "$metadata_values"

artifact_path="$bundle_dir/$ARTIFACT_FILENAME"
checksum_path="$artifact_path.sha256"
announcement_path="$bundle_dir/$ANNOUNCEMENT_FILENAME"

# When a specific prepare run is requested, the bundle must prove it originated
# from that exact run rather than from another artifact with similar contents.
if [ -n "$expected_prepare_run_id" ] && [ "$PREPARE_RUN_ID" != "$expected_prepare_run_id" ]; then
  printf '%s\n' "Prepared release bundle run ID $PREPARE_RUN_ID does not match requested run ID $expected_prepare_run_id" >&2
  exit 1
fi

require_file "$artifact_path" "Prepared artifact ZIP not found: $artifact_path"
require_file "$checksum_path" "Prepared checksum file not found: $checksum_path"
require_file "$announcement_path" "Prepared announcement draft not found: $announcement_path"

announcement_trimmed=$(
  python3 - "$announcement_path" <<'PY'
import sys
from pathlib import Path

# Strip surrounding whitespace so a draft containing only blank lines cannot
# accidentally pass validation and be submitted as an empty CTAN announcement.
text = Path(sys.argv[1]).read_text(encoding="utf-8")
print(text.strip())
PY
)

if [ -z "$announcement_trimmed" ]; then
  printf '%s\n' "Prepared announcement draft is empty or whitespace only: $announcement_path" >&2
  exit 1
fi

checksum_value=$(awk 'NR==1 { print $1 }' "$checksum_path")
checksum_target=$(awk 'NR==1 { print $2 }' "$checksum_path")
actual_checksum=$(sha256sum "$artifact_path" | awk '{print $1}')

# Cross-check metadata, checksum file, and actual artifact bytes. All three must
# agree before the bundle is considered releasable.
if [ "$checksum_value" != "$ARTIFACT_SHA256" ]; then
  printf '%s\n' "release-metadata.json SHA256 does not match checksum file." >&2
  exit 1
fi

if [ "$actual_checksum" != "$ARTIFACT_SHA256" ]; then
  printf '%s\n' "Prepared artifact SHA256 does not match release metadata." >&2
  exit 1
fi

if [ "$checksum_target" != "$ARTIFACT_FILENAME" ]; then
  printf '%s\n' "Checksum file must reference artifact filename '$ARTIFACT_FILENAME' but references '$checksum_target'." >&2
  exit 1
fi

# Guard against stale upload metadata: the frozen release version must match
# the versions embedded in the package files inside the ZIP that CTAN receives.
artifact_versions=$(
  python3 - "$artifact_path" "$VERSION" <<'PY'
import re
import sys
import zipfile

artifact_path = sys.argv[1]
expected_version = sys.argv[2]
cls_member = "onlinebrief24/onlinebrief24.cls"
doc_member = "onlinebrief24/onlinebrief24-doc.tex"

try:
    with zipfile.ZipFile(artifact_path) as archive:
        try:
            cls_text = archive.read(cls_member).decode("utf-8")
        except KeyError as exc:
            raise SystemExit(f"Prepared artifact missing required file: {cls_member}") from exc

        try:
            doc_text = archive.read(doc_member).decode("utf-8")
        except KeyError as exc:
            raise SystemExit(f"Prepared artifact missing required file: {doc_member}") from exc
except zipfile.BadZipFile as exc:
    raise SystemExit(f"Prepared artifact is not a readable ZIP archive: {artifact_path}") from exc

cls_match = re.search(
    r"\\ProvidesClass\{onlinebrief24\}\[([0-9]{4}/[0-9]{2}/[0-9]{2})\b",
    cls_text,
)
if not cls_match:
    raise SystemExit(
        "Could not extract \\ProvidesClass date from onlinebrief24.cls inside the prepared artifact."
    )

doc_match = re.search(r"\\date\{([0-9]{4}-[0-9]{2}-[0-9]{2})\}", doc_text)
if not doc_match:
    raise SystemExit(
        "Could not extract \\date from onlinebrief24-doc.tex inside the prepared artifact."
    )

cls_version = cls_match.group(1).replace("/", "-")
doc_version = doc_match.group(1)

if cls_version != expected_version:
    raise SystemExit(
        f"Prepared artifact class version {cls_version} does not match release metadata version {expected_version}."
    )

if doc_version != expected_version:
    raise SystemExit(
        f"Prepared artifact documentation date {doc_version} does not match release metadata version {expected_version}."
    )

print(f"ARTIFACT_CLASS_VERSION={cls_version}")
print(f"ARTIFACT_DOC_VERSION={doc_version}")
PY
)

eval "$artifact_versions"

if ! git -C "$repo_root" rev-parse --verify "${SOURCE_COMMIT_SHA}^{commit}" >/dev/null 2>&1; then
  printf '%s\n' "Prepared source commit is not available locally: $SOURCE_COMMIT_SHA" >&2
  exit 1
fi

# Print the resolved identifiers so release logs show exactly which artifact and
# commit were accepted for publishing.
printf '%s\n' "Validated prepared release bundle: $bundle_dir"
printf '%s\n' "Prepared artifact: $ARTIFACT_FILENAME"
printf '%s\n' "Prepared version: $VERSION"
printf '%s\n' "Artifact class version: $ARTIFACT_CLASS_VERSION"
printf '%s\n' "Artifact doc version: $ARTIFACT_DOC_VERSION"
printf '%s\n' "Prepared commit: $SOURCE_COMMIT_SHA"
