# Contributing

Thank you for your interest in improving **onlinebrief24**. Contributions of all kinds are welcome — bug reports, translations, new examples, and code improvements.

## Ways to contribute

### Report a bug

Open an issue using the **Bug Report** template. Please include:
- A minimal `.tex` file that reproduces the problem
- The TeX engine you used (`pdflatex`, `xelatex`, or `lualatex`)
- Your TeX Live version (`tlmgr --version`)
- The full LaTeX error or unexpected output

### Request a feature

Open an issue using the **Feature Request** template and describe the use case. Keep in mind that the class is intentionally focused on DIN 5008 type-B letters for onlinebrief24.de, so feature requests should fit that scope.

### Add or improve a translation

The infoblock label set currently covers German, English, French, Spanish, Italian, Dutch, and Polish. To add a new language or correct an existing translation:

1. Fork the repository and create a branch.
2. In `onlinebrief24.cls`, find the block of `\@obb@defineinfoblocklabel` calls for an existing language (e.g., `english`) and add a corresponding block for the new language, using the same eight keys:
   `yourref`, `yourmessage`, `ourref`, `ourmessage`, `contactname`, `contactphone`, `contactfax`, `contactemail`
3. Add a regression fixture in `tests/fixtures/` that uses `lang=<yourlanguage>` and sets all infoblock fields.
4. Run `sh scripts/verify.sh` (requires a local TeX Live installation) and confirm the fixture compiles without errors.
5. Open a pull request.

### Submit a new example

Examples live in `examples/` and must be named `example-onlinebrief24-*.tex`. A good example demonstrates one specific feature or combination of options. Copy an existing example as a starting point, adapt the content, and make sure it compiles with at least XeLaTeX.

### Improve the code

1. Fork the repository and create a branch from `main`.
2. Run the full verification suite before opening a pull request:
   ```sh
   sh scripts/verify.sh                          # default: xelatex
   OB24_TEX_ENGINE=lualatex sh scripts/verify.sh
   OB24_TEX_ENGINE=pdflatex sh scripts/verify.sh
   ```
3. Update `CHANGELOG.md` under `## Unreleased` with a brief description of your change.
5. Open a pull request against `main` using the PR template.

## Development setup

Requirements: TeX Live (recent, with `latexmk`), `poppler-utils` (for `pdftotext`), and POSIX shell.

```sh
# Clone
git clone https://github.com/frluciano/latex-onlinebrief24.git
cd latex-onlinebrief24

# Compile a single example
latexmk -xelatex examples/example-onlinebrief24-basic.tex

# Run the full verification suite
sh scripts/verify.sh
```

## Code style

- All internal macros must use the `\@obb@` prefix.
- Options must be declared before `\ProcessKeyvalOptions*`.
- Use `\iftex` for engine detection, never `\ifdefined\pdfoutput`.
- Fail fast with `\ClassError` or `\ClassWarningNoLine`; never fail silently.
- Keep the class POSIX-sh-scriptable: no mandatory interactive prompts.

## Questions

Open an issue or start a GitHub Discussion if you are unsure whether your idea fits the project.
