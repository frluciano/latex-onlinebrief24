# CTAN Release Workflow

This project now uses two strictly separated GitHub Actions workflows:

- `Prepare CTAN Release`
- `Release CTAN`

The prepare workflow never publishes to CTAN and has no access to CTAN release
credentials. The release workflow publishes only a previously prepared artifact
and only after explicit human approval.

## Architecture Note

### Separation of prepare and release

`Prepare CTAN Release` is responsible for:

- building the CTAN ZIP
- generating the SHA256 checksum
- generating `announcement-draft.txt`
- generating `release-metadata.json`
- validating the prepared release bundle
- uploading the prepared bundle as a GitHub artifact

`Release CTAN` is responsible for:

- downloading exactly one previously prepared release bundle
- accepting only successful `Prepare CTAN Release` runs from `push` events on
  `main`
- validating artifact, checksum, metadata, and announcement draft
- waiting for explicit human approval through the protected GitHub Environment
  `ctan-release`
- publishing to CTAN only after all checks pass

The release workflow never rebuilds the CTAN package. It always publishes the
prepared ZIP from the selected prepare run.

### Approval gate

Approval happens at the `publish-to-ctan` job via the protected GitHub
Environment `ctan-release`.

This environment must use Required Reviewers. Until a reviewer approves the
job, the workflow cannot access the CTAN release secret and cannot submit
anything to CTAN.

### Credential isolation

- `Prepare CTAN Release` runs without CTAN secrets.
- `Release CTAN` validates inputs before the publish job starts.
- Only the `publish-to-ctan` job in the protected environment receives
  `CTAN_EMAIL`.

This enforces least privilege and prevents accidental publishing from build or
package jobs.

### Missing announcement prevention

The prepare workflow generates `announcement-draft.txt` from the Git commit
subjects since the last release tag.

The release workflow fails hard if:

- `announcement-draft.txt` is missing
- the file is empty
- the file contains only whitespace

There is no fallback text and no implicit default announcement.

## Prepared Release Bundle

The prepare workflow uploads one artifact named
`onlinebrief24-ctan-release-bundle`.

The bundle contains:

- `onlinebrief24-YYYY-MM-DD.zip`
- `onlinebrief24-YYYY-MM-DD.zip.sha256`
- `announcement-draft.txt`
- `release-metadata.json`

### Metadata format

`release-metadata.json` is the machine-readable contract between prepare and
release.

```json
{
  "schema_version": 1,
  "package_name": "onlinebrief24",
  "version": "2026-03-22",
  "artifact_filename": "onlinebrief24-2026-03-22.zip",
  "artifact_sha256": "<sha256>",
  "source_commit_sha": "<git-sha>",
  "prepare_run_id": 123456789,
  "prepare_run_attempt": 1,
  "build_timestamp_utc": "2026-03-22T14:11:12Z",
  "announcement_filename": "announcement-draft.txt"
}
```

## Standard Release Flow

1. Make the intended code and documentation changes on a feature branch.
2. If package behaviour changes, update examples, verification logic, or CTAN
   docs as needed.
3. Bump the version date:
   ```bash
   sh scripts/bump-version.sh YYYY-MM-DD
   ```
4. Merge the changes into `main`.
5. Wait for these workflows on `main`:
   - `Build LaTeX Verification`
   - `Prepare CTAN Release`
6. Open the finished prepare run and note its `run_id`.
7. Download or inspect the prepared artifact and review:
   - the ZIP contents
   - `release-metadata.json`
   - `announcement-draft.txt`
8. Start `Release CTAN` manually with the selected `prepare_run_id`.
9. Review and approve the `ctan-release` environment gate.
10. After approval, the workflow validates again and then submits the prepared
    artifact to CTAN.

## Requirements

- GitHub Environment `ctan-release` must exist.
- `ctan-release` must use Required Reviewers.
- Secret `CTAN_EMAIL` must be stored only in the `ctan-release` environment.
- The package must already exist on CTAN because the workflow submits updates.

## CI Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `Build LaTeX Verification` | push, PR | Build and verify examples across all engines |
| `Prepare CTAN Release` | push, PR, manual | Build and validate a non-publishing CTAN release bundle |
| `Release CTAN` | manual only | Validate a prepared bundle, wait for approval, publish to CTAN |

## Migration Note

The previous automation coupled tag pushes directly to CTAN publishing. That
path has been removed.

Important changes:

- pushing a date tag no longer publishes anything
- build/package preparation alone can never publish to CTAN
- CTAN release credentials are no longer available to the prepare workflow
- CTAN publishing now requires a manually selected prepare run
- CTAN publishing now requires approval through the protected environment
- the CTAN announcement now comes from `announcement-draft.txt` in the prepared
  bundle and must not be empty

## Local Fallback

The local build step is still:

```bash
sh scripts/build-ctan.sh
```

For release-bundle preparation outside GitHub Actions you can additionally run:

```bash
sh scripts/generate-announcement-draft.sh dist/announcement-draft.txt
sh scripts/generate-release-metadata.sh \
  dist/ctan/onlinebrief24-YYYY-MM-DD.zip \
  dist/announcement-draft.txt \
  dist/release-metadata.json
```

Manual CTAN submission is intentionally no longer documented as the primary
path here. The supported automation path is the dedicated `Release CTAN`
workflow with explicit approval.
