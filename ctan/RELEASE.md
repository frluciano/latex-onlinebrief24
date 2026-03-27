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

After a successful CTAN publish, `Sync GitHub Release` creates or updates the
matching Git tag and GitHub Release from the same validated bundle. This sync
is retryable on its own and must never be used as a reason to re-submit to
CTAN.

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

The prepare workflow generates `announcement-draft.txt` from exactly one
explicit source:

1. `ctan/release-announcement.txt`

`Prepare CTAN Release` fails closed if that file is missing, empty, or contains
only whitespace. There is no commit-based fallback and no implicit default
announcement.

On normal `pull_request` runs and `push` runs on `main`, the workflow does not
fail just because the file is absent; instead it skips release-bundle
preparation and records that the branch is not yet release-ready. On manual
prepare runs, the missing file is a hard error.

The release workflow fails hard if:

- `announcement-draft.txt` is missing
- the file is empty
- the file contains only whitespace

After a successful release, remove `ctan/release-announcement.txt` from the
working tree or the repository so the next prepare run cannot accidentally
reuse the previous announcement text.

### Prepare trigger strategy

`Prepare CTAN Release` intentionally keeps its `pull_request` trigger even
though only `push` runs on `main` are eligible for publishing.

This is a deliberate trade-off:

- PR runs catch CTAN-package regressions before merge
- the historical required check `ctan-package` stays stable for branch
  protection
- the workflow does **not** use a `paths:` filter, because that could make the
  required check disappear entirely for unrelated PRs
- instead, a lightweight change-detection step keeps the workflow visible while
  skipping the heavy TeX installation and bundle build when CTAN inputs did not
  change
- when CTAN inputs changed but `ctan/release-announcement.txt` is still absent
  on a PR, the workflow records that the branch is not release-ready yet

This keeps the default safe and predictable without paying the full packaging
cost on every PR.

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
  "version": "2026-03-27",
  "artifact_filename": "onlinebrief24-2026-03-27.zip",
  "artifact_sha256": "<sha256>",
  "source_commit_sha": "<git-sha>",
  "prepare_run_id": 123456789,
  "prepare_run_attempt": 1,
  "build_timestamp_utc": "2026-03-27T14:11:12Z",
  "announcement_filename": "announcement-draft.txt"
}
```

## Audit Trail and Summaries

The release trail is intentionally duplicated in both machine-readable files
and human-visible GitHub summaries.

### Machine-readable audit data

The canonical audit data is already part of the release artifacts:

- `release-metadata.json` from prepare
- `resolved-release-metadata.json` from release
- the ZIP checksum file

No separate third audit artifact is maintained at the moment, because these
files already pin the prepared bundle, commit, prepare run, and release run
without introducing another source of truth.

### GitHub Step Summaries

Each release-relevant workflow writes a concise summary into the GitHub Actions
run UI:

- `Prepare CTAN Release` shows version, commit, artifact, checksum, and an
  announcement preview
- `Release CTAN` shows the validated bundle provenance and the pending approval
  gate
- `Sync GitHub Release` shows the synchronized tag/release and the expected
  GitHub Release URL

When debugging a release incident, start with the summary of the relevant run
before digging into raw logs.

## Real Release Checklist

For a real CTAN release, all of the following must be true:

- the package version in the source tree is correct
- `Prepare CTAN Release` completed successfully on `main`
- `Release CTAN` is started manually with the matching `prepare_run_id`
- the `ctan-release` environment approval is granted explicitly

If any of these conditions is not met, do not approve the publish job.

After a successful CTAN publish, GitHub should automatically receive the
matching tag and GitHub Release from the same validated bundle.

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
   - the version in `release-metadata.json` matches `onlinebrief24.cls` and
     `onlinebrief24-doc.tex` inside the ZIP
   - `announcement-draft.txt`
8. Start `Release CTAN` manually with the selected `prepare_run_id`.
9. Review and approve the `ctan-release` environment gate.
10. After approval, the workflow validates again and then submits the prepared
    artifact to CTAN, including a version consistency check between metadata
    and the package files inside the ZIP.
11. The same release run archives a redacted
    `onlinebrief24-release-audit.pkg` copy so the exact CTAN upload metadata
    remains inspectable afterwards without exposing the CTAN contact email.
12. Wait for `Sync GitHub Release` to create or update the Git tag and GitHub
    Release from the validated release bundle.

## Live Validation and Retry Protocol

The fully integrated GitHub Release sync can only be validated after an
intentional successful CTAN publish. It cannot be proven end-to-end without a
real CTAN release, because the sync intentionally runs only after CTAN
completed successfully.

### First live validation after an intentional CTAN release

After the next real CTAN release, verify all of the following:

- `Release CTAN` finished successfully
- `Sync GitHub Release` started automatically from that successful release run
- the Git tag name matches the package version
- the Git tag points to `source_commit_sha`
- the GitHub Release contains:
  - the CTAN ZIP
  - the ZIP checksum
  - `announcement-draft.txt`
  - `release-metadata.json`
  - `resolved-release-metadata.json`
- the GitHub Release notes match the validated announcement draft

### Retry protocol

If CTAN succeeded but the GitHub Release sync failed:

1. do **not** rerun `Release CTAN`
2. rerun only `Sync GitHub Release`
3. pass the original `release_run_id` when using the manual retry path

This preserves the guarantee that a retry never triggers a second CTAN submit.

### Common failure pictures

- Tag already exists but points to the wrong commit:
  the sync must fail hard; fix the tag state explicitly before retrying
- GitHub Release exists but is incomplete:
  rerun `Sync GitHub Release`; it will update notes and replace assets in place
- Announcement is missing or needs revision:
  create or update `ctan/release-announcement.txt`, then regenerate the prepare
  bundle

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
| `Sync GitHub Release` | after successful `Release CTAN`, manual retry | Create or update the matching Git tag and GitHub Release from the validated bundle |

## Migration Note

The previous automation coupled tag pushes directly to CTAN publishing. That
path has been removed.

Important changes:

- pushing a date tag no longer publishes anything
- build/package preparation alone can never publish to CTAN
- CTAN release credentials are no longer available to the prepare workflow
- CTAN publishing now requires a manually selected prepare run
- CTAN publishing now requires approval through the protected environment
- the CTAN announcement now comes only from `ctan/release-announcement.txt`,
  via `announcement-draft.txt` in the prepared bundle, and must not be empty
- GitHub Releases are now synchronized from successful CTAN releases instead of
  being maintained independently

## GitHub Release Sync

`Sync GitHub Release` consumes the validated bundle artifact from a successful
`Release CTAN` run and uses it to:

- create the release tag if it does not exist yet
- verify that an existing tag already points to the exact validated commit
- create or update the matching GitHub Release
- upload the same ZIP, checksum, announcement, and metadata files used for CTAN

The sync never rebuilds the package and never re-submits anything to CTAN.

If the GitHub Release sync fails after CTAN already succeeded, rerun only
`Sync GitHub Release` with the original `release_run_id`. Do not rerun
`Release CTAN` just to repair GitHub state.

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
