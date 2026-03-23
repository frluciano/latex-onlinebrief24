"""Reusable validation helpers for the onlinebrief24 release pipeline.

Subcommands
-----------
validate-metadata <metadata_path>
    Validate release-metadata.json and print KEY=VALUE pairs to stdout.

read-announcement <announcement_path>
    Read an announcement draft, strip whitespace, and print to stdout.

validate-zip <artifact_path> <expected_version>
    Check that class and doc versions inside the ZIP match the expected version,
    and print KEY=VALUE pairs to stdout.
"""

import json
import re
import sys
import zipfile
from pathlib import Path


def cmd_validate_metadata(metadata_path_str):
    metadata_path = Path(metadata_path_str)
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


def cmd_read_announcement(announcement_path_str):
    # Strip surrounding whitespace so a draft containing only blank lines cannot
    # accidentally pass validation and be submitted as an empty CTAN announcement.
    text = Path(announcement_path_str).read_text(encoding="utf-8")
    stripped = text.strip()
    if not stripped:
        raise SystemExit(
            f"Prepared announcement draft is empty or whitespace only: {announcement_path_str}"
        )
    print(stripped)


def cmd_validate_zip(artifact_path_str, expected_version):
    cls_member = "onlinebrief24/onlinebrief24.cls"
    doc_member = "onlinebrief24/onlinebrief24-doc.tex"

    try:
        with zipfile.ZipFile(artifact_path_str) as archive:
            try:
                cls_text = archive.read(cls_member).decode("utf-8")
            except KeyError as exc:
                raise SystemExit(
                    f"Prepared artifact missing required file: {cls_member}"
                ) from exc

            try:
                doc_text = archive.read(doc_member).decode("utf-8")
            except KeyError as exc:
                raise SystemExit(
                    f"Prepared artifact missing required file: {doc_member}"
                ) from exc
    except zipfile.BadZipFile as exc:
        raise SystemExit(
            f"Prepared artifact is not a readable ZIP archive: {artifact_path_str}"
        ) from exc

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


def main():
    if len(sys.argv) < 2:
        raise SystemExit(
            "Usage: release_validation.py <subcommand> [args...]\n"
            "Subcommands: validate-metadata, read-announcement, validate-zip"
        )

    subcommand = sys.argv[1]

    if subcommand == "validate-metadata":
        if len(sys.argv) != 3:
            raise SystemExit("Usage: release_validation.py validate-metadata <metadata_path>")
        cmd_validate_metadata(sys.argv[2])

    elif subcommand == "read-announcement":
        if len(sys.argv) != 3:
            raise SystemExit("Usage: release_validation.py read-announcement <announcement_path>")
        cmd_read_announcement(sys.argv[2])

    elif subcommand == "validate-zip":
        if len(sys.argv) != 4:
            raise SystemExit(
                "Usage: release_validation.py validate-zip <artifact_path> <expected_version>"
            )
        cmd_validate_zip(sys.argv[2], sys.argv[3])

    else:
        raise SystemExit(
            f"Unknown subcommand: {subcommand!r}\n"
            "Subcommands: validate-metadata, read-announcement, validate-zip"
        )


if __name__ == "__main__":
    main()
