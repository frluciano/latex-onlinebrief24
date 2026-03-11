# CTAN Preparation Tasks

This branch prepares `onlinebrief24` for a future CTAN submission without
forcing the GitHub-facing README or repository layout to match CTAN directly.

## Goals

- Keep the GitHub project workflow intact
- Add the missing English-facing CTAN assets
- Add a reproducible way to assemble a CTAN upload archive
- Verify that the documentation and archive can be built locally

## Work Items

- [x] Create a dedicated CTAN preparation branch
- [x] Capture the CTAN workstream in this task file
- [x] Add a CTAN-specific source directory in the repository
- [x] Add an English CTAN README
- [x] Add an English package documentation source file
- [x] Add a script that assembles a clean CTAN release directory
- [x] Add a CI workflow that rebuilds the CTAN upload artifact
- [x] Decide which example files belong in the CTAN payload
- [x] Build the CTAN documentation PDF locally
- [x] Build the CTAN release directory locally
- [x] Review the generated payload for unwanted files
- [x] Prepare the metadata needed for the CTAN upload form
- [x] Add a short explanation of what onlinebrief24.de does in the public-facing texts
- [x] Finalize the CTAN-facing wording in the English assets
- [x] Finalize the exact file naming inside the CTAN payload
- [x] Decide whether the CTAN examples set should stay as-is or be reduced
- [ ] Perform the final manual CTAN web upload

## Current Gaps

- The repository README is German and optimized for GitHub, not CTAN
- The actual CTAN web upload still needs to be done manually

## Completed on This Branch

- Created branch `ctan-prep`
- Added CTAN-specific sources under `ctan/`
- Added an English CTAN README
- Added an English package documentation source
- Added a CTAN release assembly script
- Added a CI workflow that rebuilds the CTAN upload ZIP and publishes it as an artifact
- Added a CTAN submission metadata file
- Added a short service description for onlinebrief24.de in the public-facing texts
- Finalized the English CTAN-facing wording and payload file naming
- Verified the documentation build locally
- Verified the CTAN release directory and upload ZIP locally

## Verified Commands

- `latexmk -pdf -interaction=nonstopmode -halt-on-error -outdir=/tmp/onlinebrief24-ctan-doc ctan/onlinebrief24-doc.tex`
- `sh scripts/build-ctan.sh`

## CI Reproduction

The repository now contains a dedicated GitHub Actions workflow at
`.github/workflows/build-ctan.yml`.

For future package updates, the intended flow is:

1. Update the class, CTAN-facing texts, or examples in the repository.
2. Let the regular verification workflow pass.
3. Let the CTAN package workflow rebuild `dist/ctan/onlinebrief24.zip` in CI.
4. Download the `onlinebrief24-ctan-package` artifact from the workflow run.
5. Upload that exact ZIP to CTAN.

The CI artifact should therefore be treated as the canonical upload candidate
for future CTAN updates.

## Current CTAN Payload Decision

The generated CTAN package currently contains:

- `onlinebrief24.cls`
- `README`
- `LICENSE`
- `onlinebrief24-doc.tex`
- `onlinebrief24-doc.pdf`
- `examples/example-basic.tex`
- `examples/example-modern.tex`

The payload deliberately excludes:

- Git metadata and GitHub workflow files
- local build artifacts
- generated example PDFs
- repository-only helper files outside the CTAN path

## Remaining Manual Decisions

- Confirm the final public maintainer contact email
- Perform the CTAN web upload with the ZIP from the CI artifact or an intentional local rebuild

## Notes

- CTAN should receive a clean archive with top-level directory `onlinebrief24/`
- The upload payload should avoid GitHub-only files and local build artifacts
- The public repository can stay German while the CTAN-facing assets are English
- Public-facing texts should briefly explain that onlinebrief24.de is a hybrid mail service
- Future CTAN updates should be reproducible from CI via the dedicated package-build workflow
