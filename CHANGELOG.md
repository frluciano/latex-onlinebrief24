# Changelog

All notable changes to `onlinebrief24` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added
- CHANGELOG.md with full project history
- Semantic versioning (`v1.0.0` in `\ProvidesClass`)
- pdfLaTeX support via engine-aware font loading (`fontenc`/`tgheros` fallback)
- Configurable document language (`lang=<babel name>` class option, default: `ngerman`)
- Version bump script (`scripts/bump-version.sh`)
- pdfLaTeX added as third engine in CI verification matrix

## [1.0.0] - 2026-03-10

Initial CTAN release.

### Added (2026-03-01)
- DIN 5008 type-B letter class based on KOMA-Script `scrlttr2` (`049e405`)
- Guides mode with technical overlay: address window zones, fold marks,
  dimension markers, text alignment line (`330e715`)
- Separate example files for guides and basic modes (`fb79320`)
- Project structure with LICENSE (LPPL 1.3c), README, and `.gitignore` (`e6692de`)

### Added (2026-03-01) — Modern Style
- `modern` option with header (sender name/address) and footer (contact
  details: phone, email, web, LinkedIn) (`19c32ca`)
- 8 color schemes inspired by moderncv: grey, blue, orange, green, red,
  purple, burgundy, black (`2e1c96b`)
- `footercenter` option for centered footer alignment (`2e1c96b`)
- `basic` option (renamed from `final`) as explicit default style (`68b3ace`)

### Fixed (2026-03-01)
- Guides: fold mark labels positioned vertically at line end (`7dc0746`)
- Guides: text alignment label horizontal and left-aligned (`44d9ab6`)
- Duplicate date in output removed (`b0cda44`)
- Date format and position corrected (`be718c1`)
- Zone 1 underline: replaced TikZ path with simple `\rule` for
  reliability (`cee8259`)
- Footer scoping issues resolved across color schemes (`2e1c96b`)

### Changed (2026-03-10) — Calibration
- Address window and guides calibrated 1mm lower to match real
  onlinebrief24.de preview output (`2dc4da1`, `59874e5`)
- Example sender and recipient data refreshed (`263df22`)

### Added (2026-03-11) — Hardening & CI
- Multipage layout hardening: address window, fold marks, and modern
  header/footer confined to page 1 only (`e1ebccf`)
- Regression test: validates page 2 has no leaked overlay content and
  text starts near normal top margin (`e1ebccf`)
- Verified LuaLaTeX support with reproducible font caching via
  repo-local `.texlive-cache/` (`4b11339`)
- CI workflow `Verify`: dual-engine matrix (XeLaTeX + LuaLaTeX) on every
  push and PR (`e1ebccf`, `4b11339`)
- CI workflow `Build CTAN Package`: automated artifact build with
  SHA256 checksum (`97881ab`)
- CTAN submission workflow documented in `ctan/RELEASE.md` (`263977e`)
- English CTAN documentation (`ctan/onlinebrief24-doc.tex`) (`97881ab`)
- Mandatory field validation: return address required with 72mm width
  check, recipient required (`049e405`)
- Font fallback: Arial preferred, TeX Gyre Heros as fallback (`049e405`)

### Removed
- Unused `.doc` template from resources (`7d8aec4`)
- Old specification document (`cd4178e`)
- Compiled PDFs from examples directory (`2c0cf81`)
