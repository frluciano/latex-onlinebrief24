#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

for example in \
  examples/example-basic.tex \
  examples/example-basic-guides.tex \
  examples/example-guides.tex \
  examples/example-modern.tex \
  examples/example-modern-blue.tex \
  examples/example-modern-guides.tex \
  examples/example-multipage-regression.tex
do
  latexmk -xelatex -interaction=nonstopmode -halt-on-error -cd "$example"
done

page_two_text=$(pdftotext -f 2 -l 2 examples/example-multipage-regression.pdf -)
page_two_bbox=$(pdftotext -f 2 -l 2 -bbox examples/example-multipage-regression.pdf -)
page_two_first_ymin=$(printf '%s\n' "$page_two_bbox" | sed -n 's/.*yMin="\([0-9.]*\)".*/\1/p' | head -n 1)

if printf '%s' "$page_two_text" | grep -F "Erika Mustermann, Blumenweg 1, 54321 Blumenstadt" >/dev/null; then
  printf '%s\n' "Multipage regression failed: return address leaked onto page 2." >&2
  exit 1
fi

if printf '%s' "$page_two_text" | grep -F "Mustermann GmbH & Co. KG" >/dev/null; then
  printf '%s\n' "Multipage regression failed: recipient block leaked onto page 2." >&2
  exit 1
fi

if [ -z "$page_two_first_ymin" ]; then
  printf '%s\n' "Multipage regression failed: could not determine page 2 text position." >&2
  exit 1
fi

if ! awk "BEGIN { exit !($page_two_first_ymin < 120) }"; then
  printf '%s\n' "Multipage regression failed: page 2 text still starts too low (yMin=$page_two_first_ymin)." >&2
  exit 1
fi

printf '%s\n' "Verification passed."
