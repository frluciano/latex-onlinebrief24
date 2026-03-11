# onlinebrief24

`onlinebrief24` is a LaTeX class for DIN 5008 type-B business
letters calibrated for use with `onlinebrief24.de`.

`onlinebrief24.de` is a hybrid mail service for business customers: documents
are submitted digitally, and the service handles printing, enveloping,
franking, and postal delivery.

This package is a community project and has no official affiliation with
letterei.de Postdienste GmbH. "Onlinebrief24" is a trademark of its respective
owners. The trademark holders have formally authorized the maintainer to use
the mark in connection with this LaTeX class.

## Features

- DIN 5008 type-B letter layout calibrated against the onlinebrief24.de preview
- `basic` style without header and footer
- `modern` style with header, footer, and configurable accent color
- `guides` overlay mode for technical layout inspection
- `footercenter` option for centered modern footers
- verified XeLaTeX and LuaLaTeX workflows

## Requirements

- XeLaTeX or LuaLaTeX
- `pdflatex` is not supported because the class uses `fontspec`
- Arial is preferred if installed; otherwise the class falls back to
  `TeX Gyre Heros`

## Installation

After the package has propagated from CTAN into your TeX distribution, install
it with your distribution's package manager if that route is available to you.

For direct use, development snapshots, or local testing, place
`onlinebrief24.cls` next to your letter document, or install the current class
file into your local `TEXMFHOME` tree:

```bash
kpsewhich -var-value TEXMFHOME
mkdir -p "$(kpsewhich -var-value TEXMFHOME)/tex/latex/onlinebrief24"
cp onlinebrief24.cls "$(kpsewhich -var-value TEXMFHOME)/tex/latex/onlinebrief24/"
texhash
```

## Documentation

See `onlinebrief24-doc.pdf` for usage details, options, examples, and current
limitations.

## Package Contents

- `onlinebrief24.cls`: class file
- `onlinebrief24-doc.tex`: documentation source
- `onlinebrief24-doc.pdf`: compiled documentation
- `examples/example-basic.tex`: plain example letter
- `examples/example-modern.tex`: modern example letter
- `LICENSE`: LPPL 1.3c license text

## Project URLs

- Repository: <https://github.com/frluciano/latex-onlinebrief24>
- Homepage / target service: <https://onlinebrief24.de>

## License

This package is distributed under the LaTeX Project Public License (LPPL) 1.3c.
