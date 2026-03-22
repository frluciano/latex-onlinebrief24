# onlinebrief24

`onlinebrief24` is a LaTeX class for DIN 5008 type-B business
letters calibrated for use with the `onlinebrief24.de` service.

`onlinebrief24.de` is a hybrid mail service for business customers: documents
are submitted digitally, and the service handles printing, enveloping,
franking, and postal delivery.

This package is a community project and has no official affiliation with
letterei.de Postdienste GmbH. "onlinebrief24.de" is a trademark of its respective
owners. The trademark holders have formally authorized the maintainer to use
the mark in connection with this LaTeX class.

## Features

- DIN 5008 type-B letter layout calibrated against the onlinebrief24.de preview
- `basic` style without header and footer
- `modern` style with header, footer, and configurable accent color
- optional DIN-style information block in the upper-right header area
- `guides` overlay mode for technical layout inspection
- `footercenter` option for centered modern footers
- verified pdfLaTeX, XeLaTeX, and LuaLaTeX workflows

## Requirements

- pdfLaTeX, XeLaTeX, or LuaLaTeX
- With pdfLaTeX the class uses `fontenc`/`tgheros`; with XeLaTeX/LuaLaTeX
  it uses `fontspec` (Arial preferred, TeX Gyre Heros as fallback)
- The `modern` style additionally requires `fontawesome5` (for footer icons)
  and `sourcesanspro`; both are included in `texlive-fonts-extra`

## Installation

Install via your TeX distribution's package manager:

```bash
tlmgr install onlinebrief24
```

## Documentation

See `onlinebrief24-doc.pdf` for usage details, options, examples, and current
limitations.

## Package Contents

- `onlinebrief24.cls`: class file
- `onlinebrief24-doc.tex`: documentation source
- `onlinebrief24-doc.pdf`: compiled documentation
- `examples/example-onlinebrief24-basic.tex`: plain example letter
- `examples/example-onlinebrief24-basic.pdf`: compiled plain example
- `examples/example-onlinebrief24-infoblock.tex`: information-block example
- `examples/example-onlinebrief24-infoblock.pdf`: compiled information-block example
- `examples/example-onlinebrief24-modern.tex`: modern example letter
- `examples/example-onlinebrief24-modern.pdf`: compiled modern example
- `examples/example-onlinebrief24-modern-blue.tex`: alternate modern color-scheme example
- `examples/example-onlinebrief24-modern-blue.pdf`: compiled alternate modern example
- `LICENSE`: LPPL 1.3c license text

## Project URLs

- Repository: <https://github.com/frluciano/latex-onlinebrief24>
- Homepage / target service: <https://onlinebrief24.de>

## Maintainer

- Francesco Luciano
- Repository: <https://github.com/frluciano/latex-onlinebrief24>
- Bug reports: <https://github.com/frluciano/latex-onlinebrief24/issues>

## License

This package is distributed under the LaTeX Project Public License (LPPL) 1.3c.
