"""Helpers for GitHub Actions release workflows.

Subcommands
-----------
validate-prepare-run-provenance <repo> <run_id>
    Ensure the selected Actions run is a successful push-to-main prepare run.

read-prepared-metadata <bundle_dir>
    Print selected release-metadata.json fields as KEY=VALUE lines.

record-resolved-release-metadata <bundle_dir> <release_run_id> <release_run_attempt> <actor>
    Write resolved-release-metadata.json next to the prepared bundle.

write-prepare-summary <bundle_dir> <event_name> <prepare_run_id> <prepare_run_attempt> <bundle_artifact_name>
    Print the prepare-job markdown summary to stdout.

write-release-validation-summary <bundle_dir>
    Print the manual release validation markdown summary to stdout.

write-ctan-publish-summary <bundle_dir> <rendered_pkg_artifact_name>
    Print the CTAN publish markdown summary to stdout.

validate-release-run-provenance <repo> <run_id>
    Ensure the selected Actions run is a successful workflow_dispatch release run.

read-resolved-release-metadata <bundle_dir> <expected_release_run_id>
    Print selected resolved-release-metadata.json fields as KEY=VALUE lines.

write-sync-github-release-summary <bundle_dir> <trigger_event_name> <github_repository>
    Print the GitHub release sync markdown summary to stdout.
"""

import json
import re
import subprocess
import sys
import zipfile
from datetime import datetime, timezone
from pathlib import Path

from . import release_validation


def load_json(path_str):
    path = Path(path_str)
    return path, json.loads(path.read_text(encoding="utf-8"))


def print_key_values(data, keys):
    for key in keys:
        print(f"{key}={data[key]}")


def require_fields(data, keys, error_prefix):
    missing = [key for key in keys if not data.get(key)]
    if missing:
        raise SystemExit(f"{error_prefix}{', '.join(missing)}")


def load_bundle_metadata(bundle_dir_str):
    bundle_dir = Path(bundle_dir_str)
    metadata_path = bundle_dir / "release-metadata.json"
    if not metadata_path.exists():
        raise SystemExit(f"::error file={metadata_path}::Missing prepared release metadata.")
    _, data = load_json(str(metadata_path))
    return bundle_dir, metadata_path, data


def load_resolved_metadata(bundle_dir_str):
    bundle_dir = Path(bundle_dir_str)
    resolved_path = bundle_dir / "resolved-release-metadata.json"
    if not resolved_path.exists():
        raise SystemExit(f"::error file={resolved_path}::Missing resolved release metadata.")
    _, data = load_json(str(resolved_path))
    return bundle_dir, resolved_path, data


def read_run(repo, run_id):
    raw = subprocess.check_output(
        ["gh", "api", f"repos/{repo}/actions/runs/{run_id}"],
        text=True,
    )
    return json.loads(raw)


def extract_zip_versions(bundle_dir, metadata):
    artifact_path = bundle_dir / metadata["artifact_filename"]
    artifact_version_match = re.fullmatch(
        r"onlinebrief24-([0-9]{4}-[0-9]{2}-[0-9]{2})\.zip",
        metadata["artifact_filename"],
    )
    if not artifact_version_match:
        raise SystemExit(
            f"::error file={artifact_path}::Could not derive version from artifact filename."
        )

    cls_version, doc_version = release_validation.get_zip_versions(artifact_path)

    return (
        artifact_path,
        artifact_version_match.group(1),
        cls_version,
        doc_version,
    )


def cmd_validate_prepare_run_provenance(repo, run_id):
    data = read_run(repo, run_id)
    errors = []

    if data.get("name") != "Prepare CTAN Release":
        errors.append(f"prepare run {run_id} is not from 'Prepare CTAN Release'")
    if data.get("event") != "push":
        errors.append(f"prepare run {run_id} must come from a push event")
    if data.get("head_branch") != "main":
        errors.append(f"prepare run {run_id} must come from main, got {data.get('head_branch')!r}")
    if data.get("status") != "completed" or data.get("conclusion") != "success":
        errors.append(f"prepare run {run_id} must be completed successfully")

    if errors:
        for message in errors:
            print(f"::error::{message}")
        raise SystemExit(1)


def cmd_read_prepared_metadata(bundle_dir_str):
    _, metadata_path, data = load_bundle_metadata(bundle_dir_str)
    required = ("artifact_filename", "prepare_run_id", "source_commit_sha", "version")
    require_fields(
        data,
        required,
        f"::error file={metadata_path}::Missing required metadata fields: ",
    )
    print_key_values(data, required)


def cmd_record_resolved_release_metadata(
    bundle_dir_str, release_run_id, release_run_attempt, actor
):
    bundle_dir, _, data = load_bundle_metadata(bundle_dir_str)
    resolved_path = bundle_dir / "resolved-release-metadata.json"

    data["release_run_id"] = release_run_id
    data["release_run_attempt"] = release_run_attempt
    data["release_requested_by"] = actor
    data["release_timestamp_utc"] = (
        datetime.now(timezone.utc).replace(microsecond=0).isoformat().replace("+00:00", "Z")
    )

    resolved_path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")


def cmd_write_prepare_summary(
    bundle_dir_str, event_name, prepare_run_id, prepare_run_attempt, bundle_artifact_name
):
    bundle_dir, _, metadata = load_bundle_metadata(bundle_dir_str)
    announcement_lines = (
        (bundle_dir / metadata["announcement_filename"]).read_text(encoding="utf-8").strip().splitlines()
    )
    announcement_preview = "<br>".join(
        line.replace("|", "\\|") for line in announcement_lines[:4]
    ) or "(empty)"

    print("## Prepare CTAN Release")
    print()
    print("| Field | Value |")
    print("| --- | --- |")
    print(f"| Event | {event_name} |")
    print(f"| Prepare run ID | `{prepare_run_id}` |")
    print(f"| Prepare run attempt | `{prepare_run_attempt}` |")
    print(f"| Source commit | `{metadata['source_commit_sha']}` |")
    print(f"| Version | `{metadata['version']}` |")
    print(f"| Artifact | `{metadata['artifact_filename']}` |")
    print(f"| SHA256 | `{metadata['artifact_sha256']}` |")
    print(f"| Bundle artifact | `{bundle_artifact_name}` |")
    print(f"| Announcement draft | `{metadata['announcement_filename']}` |")
    print()
    print("Announcement preview:")
    print()
    print(announcement_preview)


def cmd_write_release_validation_summary(bundle_dir_str):
    bundle_dir, _, metadata = load_bundle_metadata(bundle_dir_str)
    _, resolved_path, resolved = load_resolved_metadata(bundle_dir_str)
    artifact_path, artifact_filename_version, cls_version, doc_version = extract_zip_versions(
        bundle_dir, metadata
    )
    announcement_text = (
        (bundle_dir / metadata["announcement_filename"]).read_text(encoding="utf-8").strip()
    ) or "(empty)"

    if not resolved.get("release_run_id") or not resolved.get("release_requested_by"):
        raise SystemExit(
            f"::error file={resolved_path}::Missing release identity fields required for the validation summary."
        )

    print("## Release CTAN validation")
    print()
    print("| Field | Value |")
    print("| --- | --- |")
    print(f"| Requested prepare run | `{metadata['prepare_run_id']}` |")
    print(f"| Release run | `{resolved['release_run_id']}` |")
    print(f"| Release actor | `{resolved['release_requested_by']}` |")
    print(f"| Source commit | `{metadata['source_commit_sha']}` |")
    print(f"| Artifact | `{metadata['artifact_filename']}` |")
    print(f"| SHA256 | `{metadata['artifact_sha256']}` |")
    print("| Approval gate | `ctan-release` environment pending after validation |")
    print()
    print("Version cross-check:")
    print()
    print("| `release-metadata.json` | ZIP filename | `onlinebrief24.cls` in ZIP | `onlinebrief24-doc.tex` in ZIP |")
    print("| --- | --- | --- | --- |")
    print(
        f"| `{metadata['version']}` | `{artifact_filename_version}` | `{cls_version}` | `{doc_version}` |"
    )
    print()
    print("Announcement:")
    print()
    print("```text")
    print(announcement_text.replace("```", "'''"))
    print("```")
    print()
    print(
        "Next step: approve the `ctan-release` deployment before `publish-to-ctan` can access CTAN credentials."
    )


def cmd_write_ctan_publish_summary(bundle_dir_str, rendered_pkg_artifact_name):
    bundle_dir, _, metadata = load_bundle_metadata(bundle_dir_str)
    _, resolved_path, resolved = load_resolved_metadata(bundle_dir_str)
    artifact_path, artifact_filename_version, cls_version, doc_version = extract_zip_versions(
        bundle_dir, metadata
    )
    rendered_pkg_path = bundle_dir / "onlinebrief24-release-audit.pkg"
    pkg_text = rendered_pkg_path.read_text(encoding="utf-8")

    pkg_version_match = re.search(r"\\version\{([0-9]{4}-[0-9]{2}-[0-9]{2})\}", pkg_text)
    pkg_file_match = re.search(r"\\file\{([^}]*)\}", pkg_text)
    if not pkg_version_match or not pkg_file_match:
        raise SystemExit(
            f"::error file={rendered_pkg_path}::Could not extract one or more release-version fields for the publish summary."
        )

    if not resolved.get("release_run_id"):
        raise SystemExit(
            f"::error file={resolved_path}::Missing release_run_id required for the publish summary."
        )

    pkg_version = pkg_version_match.group(1)
    pkg_artifact_name = Path(pkg_file_match.group(1)).name

    print("## CTAN publish completed")
    print()
    print("| Field | Value |")
    print("| --- | --- |")
    print(f"| Prepare run | `{metadata['prepare_run_id']}` |")
    print(f"| Release run | `{resolved['release_run_id']}` |")
    print(f"| Source commit | `{metadata['source_commit_sha']}` |")
    print(f"| Artifact | `{metadata['artifact_filename']}` |")
    print(f"| SHA256 | `{metadata['artifact_sha256']}` |")
    print(f"| Rendered `.pkg` artifact | `{rendered_pkg_artifact_name}` |")
    print(f"| Rendered `.pkg` audit copy | `{rendered_pkg_path.name}` |")
    print(f"| Rendered `.pkg` file target | `{pkg_artifact_name}` |")
    print()
    print("Version cross-check:")
    print()
    print("| `release-metadata.json` | ZIP filename | `onlinebrief24.cls` in ZIP | `onlinebrief24-doc.tex` in ZIP | rendered `.pkg` |")
    print("| --- | --- | --- | --- | --- |")
    print(
        f"| `{metadata['version']}` | `{artifact_filename_version}` | `{cls_version}` | `{doc_version}` | `{pkg_version}` |"
    )
    print()
    print(
        "The follow-up workflow `Sync GitHub Release` should now create or update the matching Git tag and GitHub Release from the same validated bundle."
    )


def cmd_validate_release_run_provenance(repo, run_id):
    data = read_run(repo, run_id)
    errors = []

    if data.get("name") != "Release CTAN":
        errors.append(f"release run {run_id} is not from 'Release CTAN'")
    if data.get("event") != "workflow_dispatch":
        errors.append(f"release run {run_id} must come from a workflow_dispatch event")
    if data.get("head_branch") != "main":
        errors.append(f"release run {run_id} must come from main, got {data.get('head_branch')!r}")
    if data.get("status") != "completed" or data.get("conclusion") != "success":
        errors.append(f"release run {run_id} must be completed successfully")

    if errors:
        for message in errors:
            print(f"::error::{message}")
        raise SystemExit(1)


def cmd_read_resolved_release_metadata(bundle_dir_str, expected_release_run_id):
    _, resolved_path, data = load_resolved_metadata(bundle_dir_str)
    required = ("artifact_filename", "release_run_id", "source_commit_sha", "version")
    require_fields(
        data,
        required,
        f"::error file={resolved_path}::Missing required resolved metadata fields: ",
    )

    if str(data["release_run_id"]) != expected_release_run_id:
        raise SystemExit(
            f"::error file={resolved_path}::Resolved metadata release_run_id {data['release_run_id']} "
            f"does not match triggering release run ID {expected_release_run_id}."
        )

    print_key_values(data, required)


def cmd_write_sync_github_release_summary(bundle_dir_str, trigger_event_name, github_repository):
    bundle_dir, _, metadata = load_bundle_metadata(bundle_dir_str)
    _, resolved_path, resolved = load_resolved_metadata(bundle_dir_str)
    version = metadata["version"]
    release_url = f"https://github.com/{github_repository}/releases/tag/{version}"

    if not resolved.get("release_run_id"):
        raise SystemExit(
            f"::error file={resolved_path}::Missing release_run_id required for the sync summary."
        )

    print("## GitHub release sync completed")
    print()
    print("| Field | Value |")
    print("| --- | --- |")
    print(f"| Trigger | `{trigger_event_name}` |")
    print(f"| Prepare run | `{metadata['prepare_run_id']}` |")
    print(f"| Release run | `{resolved['release_run_id']}` |")
    print(f"| Source commit | `{metadata['source_commit_sha']}` |")
    print(f"| Version / tag | `{version}` |")
    print(f"| Artifact | `{metadata['artifact_filename']}` |")
    print(f"| SHA256 | `{metadata['artifact_sha256']}` |")
    print(f"| Release URL | {release_url} |")


def main():
    if len(sys.argv) < 2:
        raise SystemExit(
            "Usage: release_workflow.py <subcommand> [args...]\n"
            "Subcommands: validate-prepare-run-provenance, read-prepared-metadata, "
            "record-resolved-release-metadata, write-prepare-summary, "
            "write-release-validation-summary, write-ctan-publish-summary, "
            "validate-release-run-provenance, read-resolved-release-metadata, "
            "write-sync-github-release-summary"
        )

    subcommand = sys.argv[1]

    if subcommand == "validate-prepare-run-provenance":
        if len(sys.argv) != 4:
            raise SystemExit(
                "Usage: release_workflow.py validate-prepare-run-provenance <repo> <run_id>"
            )
        cmd_validate_prepare_run_provenance(sys.argv[2], sys.argv[3])
    elif subcommand == "read-prepared-metadata":
        if len(sys.argv) != 3:
            raise SystemExit(
                "Usage: release_workflow.py read-prepared-metadata <bundle_dir>"
            )
        cmd_read_prepared_metadata(sys.argv[2])
    elif subcommand == "record-resolved-release-metadata":
        if len(sys.argv) != 6:
            raise SystemExit(
                "Usage: release_workflow.py record-resolved-release-metadata "
                "<bundle_dir> <release_run_id> <release_run_attempt> <actor>"
            )
        cmd_record_resolved_release_metadata(
            sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5]
        )
    elif subcommand == "write-prepare-summary":
        if len(sys.argv) != 7:
            raise SystemExit(
                "Usage: release_workflow.py write-prepare-summary "
                "<bundle_dir> <event_name> <prepare_run_id> <prepare_run_attempt> "
                "<bundle_artifact_name>"
            )
        cmd_write_prepare_summary(
            sys.argv[2], sys.argv[3], sys.argv[4], sys.argv[5], sys.argv[6]
        )
    elif subcommand == "write-release-validation-summary":
        if len(sys.argv) != 3:
            raise SystemExit(
                "Usage: release_workflow.py write-release-validation-summary <bundle_dir>"
            )
        cmd_write_release_validation_summary(sys.argv[2])
    elif subcommand == "write-ctan-publish-summary":
        if len(sys.argv) != 4:
            raise SystemExit(
                "Usage: release_workflow.py write-ctan-publish-summary "
                "<bundle_dir> <rendered_pkg_artifact_name>"
            )
        cmd_write_ctan_publish_summary(sys.argv[2], sys.argv[3])
    elif subcommand == "validate-release-run-provenance":
        if len(sys.argv) != 4:
            raise SystemExit(
                "Usage: release_workflow.py validate-release-run-provenance <repo> <run_id>"
            )
        cmd_validate_release_run_provenance(sys.argv[2], sys.argv[3])
    elif subcommand == "read-resolved-release-metadata":
        if len(sys.argv) != 4:
            raise SystemExit(
                "Usage: release_workflow.py read-resolved-release-metadata "
                "<bundle_dir> <expected_release_run_id>"
            )
        cmd_read_resolved_release_metadata(sys.argv[2], sys.argv[3])
    elif subcommand == "write-sync-github-release-summary":
        if len(sys.argv) != 5:
            raise SystemExit(
                "Usage: release_workflow.py write-sync-github-release-summary "
                "<bundle_dir> <trigger_event_name> <github_repository>"
            )
        cmd_write_sync_github_release_summary(sys.argv[2], sys.argv[3], sys.argv[4])
    else:
        raise SystemExit(
            f"Unknown subcommand: {subcommand!r}\n"
            "Subcommands: validate-prepare-run-provenance, read-prepared-metadata, "
            "record-resolved-release-metadata, write-prepare-summary, "
            "write-release-validation-summary, write-ctan-publish-summary, "
            "validate-release-run-provenance, read-resolved-release-metadata, "
            "write-sync-github-release-summary"
        )


if __name__ == "__main__":
    main()
