# CTAN Submission Notes

This file collects the metadata needed for the CTAN upload form so the final
submission can be assembled quickly from the verified package artifacts.

## Package Identity

- Package name: `onlinebrief24`
- Suggested CTAN path: `macros/latex/contrib/onlinebrief24`
- License: `LPPL 1.3c`
- Repository: <https://github.com/frluciano/latex-onlinebrief24>
- Project homepage / target service: <https://onlinebrief24.de>

## Maintainer

- Name: Francesco Luciano
- Contact email: francesco@luciano.de

## Short Description

LaTeX class for DIN 5008 type-B business letters calibrated for use
with onlinebrief24.de.

## Long Description

`onlinebrief24` is a LaTeX letter class based on KOMA-Script `scrlttr2`. It is
calibrated against the practical preview behavior of onlinebrief24.de and
provides:

- a plain letter layout
- a modern layout with header, footer, and accent colors
- a guides mode for technical layout inspection
- validated address-window inputs
- verified XeLaTeX and LuaLaTeX workflows

The package is intended for German business letters and currently supports one
letter per document as the hardened use case.

onlinebrief24.de is a hybrid mail service for business customers: documents
are submitted digitally, and the service handles printing, enveloping,
franking, and postal delivery.

The trademark holders have formally authorized the maintainer to use the
Onlinebrief24 mark in connection with this LaTeX class.

## Suggested Topics / Captions

- Topic candidates: `class`, `letter`, `office`, `layout`
- Audience cue: LaTeX users who prepare DIN 5008 business letters for
  onlinebrief24.de

## Suggested Announcement

`onlinebrief24` is a LaTeX class for DIN 5008 type-B business letters
calibrated for use with onlinebrief24.de, a hybrid mail service for business
customers. The package is based on KOMA-Script `scrlttr2` and provides plain
and modern letter styles, a guides mode for layout inspection, validated
address-window inputs, and verified XeLaTeX and LuaLaTeX workflows.

## Upload Artifact

Build before upload:

```bash
sh scripts/build-ctan.sh
```

CI reproduction:

- Workflow: `Build CTAN Package`
- Artifact name: `onlinebrief24-ctan-package`
- Artifact contents:
  - `onlinebrief24.zip`
  - `onlinebrief24.zip.sha256`

Expected output:

- Directory: `dist/ctan/onlinebrief24/`
- Archive: `dist/ctan/onlinebrief24.zip`

## Final Manual Checks Before Upload

- Confirm the public maintainer contact email
- Re-read the announcement text for tone and length
- Confirm the package version/date matches the intended release state
- Prefer the ZIP produced by the CI workflow artifact for the final upload
- Upload the artifact ZIP, or a deliberate byte-equivalent local rebuild, through the CTAN upload form
