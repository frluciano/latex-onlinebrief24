# CTAN Release Workflow

This file documents the intended release process for `onlinebrief24` after the
initial CTAN setup. It is written for the maintainer workflow of this
repository.

## Release Principles

- `main` is the release branch
- the CI artifact from `Build CTAN Package` is the preferred upload candidate
- the class version in `onlinebrief24.cls` should match the intended CTAN
  release state
- if the CTAN documentation date is shown publicly, keep it aligned with the
  release date as well

## Files To Update Before A Release

At minimum, review these files before every CTAN update:

- `onlinebrief24.cls`
- `ctan/onlinebrief24-doc.tex`
- `ctan/CTAN-SUBMISSION.md`

Typical release edits:

- update the version/date in `\ProvidesClass{onlinebrief24}[...]`
- adjust the CTAN documentation date if needed
- refresh the announcement text if the release adds noteworthy features
- confirm the package contents still match `scripts/build-ctan.sh`

## Standard Release Flow

1. Make the intended code and documentation changes on a feature branch.
2. If the package behavior changes, update the examples, verification logic, or
   CTAN docs as needed.
3. Update the release version/date in `onlinebrief24.cls`.
4. If appropriate, update the visible date in `ctan/onlinebrief24-doc.tex`.
5. Merge the finished work into `main`.
6. Wait for both GitHub Actions workflows on `main` to complete successfully:
   - `Verify`
   - `Build CTAN Package`
7. Open the successful `Build CTAN Package` workflow run.
8. Download the artifact `onlinebrief24-ctan-package`.
9. Extract the artifact and take `onlinebrief24.zip` as the CTAN upload file.
10. Upload that ZIP through the CTAN upload interface.

## Finding The CI Artifact

1. Open the GitHub repository.
2. Go to `Actions`.
3. Open `Build CTAN Package`.
4. Select the latest successful run on `main`.
5. Download the artifact `onlinebrief24-ctan-package`.
6. Extract it locally.

The extracted artifact contains:

- `onlinebrief24.zip`
- `onlinebrief24.zip.sha256`

## CTAN Upload Guidance

For updates to an existing CTAN package, prefer starting from the package page
and using its upload link so CTAN can prefill metadata where possible.

Before the upload, confirm:

- the maintainer email in `ctan/CTAN-SUBMISSION.md`
- the release version/date
- the announcement text, if you want CTAN to publish one
- the package ZIP came from a green CI run on `main`

Use these repository files as the source of truth for upload metadata:

- `ctan/CTAN-SUBMISSION.md` for summary, description, and announcement
- `ctan/README.md` for the package-facing README
- `ctan/onlinebrief24-doc.tex` for the package documentation source

## Local Fallback

If CI is temporarily unavailable, you can rebuild the CTAN package locally:

```bash
sh scripts/build-ctan.sh
```

Expected output:

- `dist/ctan/onlinebrief24/`
- `dist/ctan/onlinebrief24.zip`

The local build is a fallback. The preferred upload candidate remains the ZIP
from the CI artifact on `main`.

## Optional GitHub Release

A GitHub release is not required for CTAN, but if you want one:

1. wait for green CI on `main`
2. tag the release commit
3. create a GitHub release pointing to that tag
4. attach the same `onlinebrief24.zip` artifact if you want the GitHub release
   to mirror the CTAN payload
