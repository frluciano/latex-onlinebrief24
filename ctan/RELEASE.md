# CTAN Release Workflow

This file documents the release process for `onlinebrief24`. Releases are
automated via the `Release CTAN` GitHub Actions workflow.

## Release Principles

- `main` is the release branch
- pushing a date tag (`YYYY-MM-DD`) triggers the automated release pipeline
- the class version in `onlinebrief24.cls` must match the tag
- the CTAN upload, GitHub Release, and artifact creation happen automatically

## Files To Update Before A Release

At minimum, review these files before every release:

- `onlinebrief24.cls` — version/date in `\ProvidesClass`
- `ctan/onlinebrief24-doc.tex` — documentation date and content
- `ctan/README.md` — package README for CTAN
- `README.md` — German project README (keep feature list in sync with ctan/README.md)
- `ctan/onlinebrief24.pkg` — announcement text (if changed)

Typical release edits:

- update the version/date in `\ProvidesClass{onlinebrief24}[...]`
- adjust the CTAN documentation date if needed
- refresh the announcement text in `ctan/onlinebrief24.pkg`
- confirm the package contents still match `scripts/build-ctan.sh`

## Standard Release Flow

1. Make the intended code and documentation changes on a feature branch.
2. If the package behavior changes, update the examples, verification logic, or
   CTAN docs as needed.
3. Bump the version date (updates both `onlinebrief24.cls` and `ctan/onlinebrief24-doc.tex`):
   ```bash
   sh scripts/bump-version.sh YYYY-MM-DD
   ```
4. Update the announcement in `ctan/onlinebrief24.pkg` if noteworthy.
6. Merge the finished work into `main`.
7. Wait for both CI workflows on `main` to pass:
   - `Build LaTeX Verification`
   - `Build CTAN Package`
8. Push an annotated tag matching the version date:
   ```bash
   git tag -a YYYY-MM-DD -m "YYYY-MM-DD — short description"
   git push origin YYYY-MM-DD
   ```
   Write the tag annotation body in English. The release workflow reuses that
   text as both the CTAN announcement and the GitHub Release notes.
9. The `Release CTAN` workflow will automatically:
   - build the CTAN package
   - validate against the CTAN API
   - upload to CTAN
   - create a GitHub Release with the ZIP and checksum attached

## Requirements

- GitHub Secret `CTAN_EMAIL` must be set to the registered CTAN uploader email
- The package must already exist on CTAN (first upload was manual)
- The tag must match the date in `\ProvidesClass{onlinebrief24}[YYYY/MM/DD ...]`

## CI Workflows

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `Build LaTeX Verification` | push, PR | Build and verify examples across all engines |
| `Build CTAN Package` | push, PR | Build CTAN ZIP artifact for validation |
| `Release CTAN` | date tag push | Build, upload to CTAN, create GitHub Release |

## Local Fallback

If CI is temporarily unavailable, you can rebuild and upload manually:

```bash
sh scripts/build-ctan.sh
```

Expected output:

- `dist/ctan/onlinebrief24/`
- `dist/ctan/onlinebrief24-YYYY-MM-DD.zip`

For manual CTAN upload, use the web form or run ctan-o-mat locally:

```bash
ctan-o-mat --submit ctan/onlinebrief24.pkg
```

## Suggested CTAN Metadata

Summary:

`LaTeX class for DIN 5008 type-B business letters calibrated for use with onlinebrief24.de.`

Long description:

`onlinebrief24` is a LaTeX letter class based on KOMA-Script `scrlttr2`. It is
calibrated against the practical preview behavior of onlinebrief24.de and
provides:

- a plain letter layout
- a modern layout with header, footer, and accent colors
- a guides mode for technical layout inspection
- validated address-window inputs
- verified pdfLaTeX, XeLaTeX, and LuaLaTeX workflows

The package is intended for German business letters and currently supports one
letter per document as the hardened use case.

onlinebrief24.de is a hybrid mail service for business customers: documents
are submitted digitally, and the service handles printing, enveloping,
franking, and postal delivery.

The trademark holders have formally authorized the maintainer to use the
Onlinebrief24 mark in connection with this LaTeX class.
