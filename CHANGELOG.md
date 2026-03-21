# Changelog

All notable changes to `onlinebrief24` will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project uses date-based versioning aligned with CTAN releases (YYYY-MM-DD).

## [2026-03-21]

### Added
- `\encl{...}` documented in README.md and CTAN documentation as the standard
  KOMA-Script command for enclosures below the closing
- Example PDFs (`basic`, `modern`) are now compiled and included in the CTAN
  package so users can preview the output without building locally

### Changed
- Default babel language changed from `ngerman` to `german` for better
  compatibility with current babel versions
- All example files renamed to the `example-onlinebrief24-*` prefix to follow
  CTAN naming conventions
- Replaced `marvosym` with `fontawesome5` for modern-style footer icons;
  `\faPhone`, `\faMobile`, `\faEnvelope`, `\faGlobe`, `\faLinkedin` replace
  the corresponding `marvosym` symbols
- Removed dead `\ifPDFTeX` branch in modern-style package loading; both branches
  loaded `sourcesanspro` identically
- CTAN README extended with maintainer name and contact URLs

### Internal
- `verify.sh` now performs content checks on the signature regression and modern
  example PDFs via `pdftotext`, not just compilation success

## [2026-03-20]

### Fixed
- Left-align `\closing` consistently when a longer `signature` is set via KOMA variables

## [2026-03-11]

### Added
- pdfLaTeX support via engine-aware font loading (`fontenc`/`tgheros` fallback)
- Configurable document language (`lang=<babel name>` class option, default: `german`)
- pdfLaTeX added as third engine in CI verification matrix

### Changed
- Date-based versioning replaces semver in `\ProvidesClass`
- All `\DeclareOption` moved before `\ProcessOptions` for correct option handling
- CI workflow renamed to `Build LaTeX Verification`

## [2026-03-10]

Initial CTAN release.

### Added
- DIN 5008 type-B letter class based on KOMA-Script `scrlttr2`
- Guides mode with technical overlay: address window zones, fold marks,
  dimension markers, text alignment line
- `modern` option with header and footer (phone, email, web, LinkedIn)
- 8 color schemes inspired by moderncv: grey, blue, orange, green, red,
  purple, burgundy, black
- `footercenter` option for centered footer alignment
- `basic` option as explicit default style
- Multipage layout hardening: overlays confined to page 1 only
- Regression test: validates page 2 has no leaked overlay content
- Verified LuaLaTeX support with reproducible font caching
- CI workflow `Build LaTeX Verification`: dual-engine matrix (XeLaTeX + LuaLaTeX)
- CI workflow `Build CTAN Package`: automated artifact build with SHA256 checksum
- CTAN submission workflow documented in `ctan/RELEASE.md`
- English CTAN documentation (`ctan/onlinebrief24-doc.tex`)
- Mandatory field validation: return address and recipient required
- Font fallback: Arial preferred, TeX Gyre Heros as fallback
- Project structure with LICENSE (LPPL 1.3c), README, and `.gitignore`

### Fixed
- Guides: fold mark labels positioned vertically at line end
- Duplicate date in output removed
- Date format and position corrected
- Zone 1 underline: replaced TikZ path with simple `\rule`
- Footer scoping issues resolved across color schemes

### Changed
- Address window and guides calibrated 1mm lower to match onlinebrief24.de preview

### Removed
- Unused `.doc` template from resources
- Old specification document
- Compiled PDFs from examples directory
