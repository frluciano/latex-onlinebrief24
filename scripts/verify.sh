#!/bin/sh
set -eu

# Resolve the repository root relative to this script so the verification
# works regardless of the caller's current working directory.
repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
cd "$repo_root"

# Select the TeX engine from the environment. XeLaTeX remains the default
# because it is the simplest local invocation, while LuaLaTeX can be enabled
# explicitly for the second verified engine path.
engine=${OB24_TEX_ENGINE:-xelatex}
case "$engine" in
  xelatex)
    # latexmk needs an explicit engine flag instead of a plain executable name.
    latexmk_engine_flag=-xelatex
    ;;
  lualatex)
    # LuaLaTeX relies on luaotfload caches. In restrictive environments
    # (sandboxed local runs or CI), the default cache location may be
    # unavailable, so we force a writable repo-local cache directory.
    latexmk_engine_flag=-lualatex
    texlive_cache_dir="$repo_root/.texlive-cache/$engine"
    mkdir -p "$texlive_cache_dir"
    export TEXMFVAR="$texlive_cache_dir"
    export TEXMFCACHE="$texlive_cache_dir"
    ;;
  pdflatex)
    latexmk_engine_flag=-pdf
    ;;
  *)
    # Fail fast on typos or unsupported engines so CI errors stay obvious.
    printf '%s\n' "Unsupported OB24_TEX_ENGINE: $engine (expected xelatex, lualatex, or pdflatex)." >&2
    exit 1
    ;;
esac

# Rebuild every maintained example document. The `-g` flag forces a fresh build
# so engine switches do not accidentally reuse stale artifacts from earlier runs.
for example in \
  examples/example-onlinebrief24-basic.tex \
  examples/example-onlinebrief24-basic-guides.tex \
  examples/example-onlinebrief24-guides.tex \
  examples/example-onlinebrief24-signature-regression.tex \
  examples/example-onlinebrief24-modern.tex \
  examples/example-onlinebrief24-modern-blue.tex \
  examples/example-onlinebrief24-modern-guides.tex \
  examples/example-onlinebrief24-multipage-regression.tex
do
  latexmk "$latexmk_engine_flag" -g -interaction=nonstopmode -halt-on-error -cd "$example"
done

# Verify that the modern-style footer fields are rendered in the output PDF.
# The modern example includes all contact fields; at minimum the email address
# must appear so we know the footer rendering path is active.
modern_text=$(pdftotext examples/example-onlinebrief24-modern.pdf -)
if ! printf '%s' "$modern_text" | grep -F "erika.mustermann@example.com" >/dev/null; then
  printf '%s\n' "Modern footer regression failed: email address not found in PDF." >&2
  exit 1
fi
if ! printf '%s' "$modern_text" | grep -F "Mustermann" >/dev/null; then
  printf '%s\n' "Modern header regression failed: sender name not found in PDF." >&2
  exit 1
fi

# Verify the signature regression: both the closing phrase and the explicit
# signature must appear in the PDF. The original bug caused the closing to be
# mis-aligned when the signature text was longer than the closing phrase.
sig_text=$(pdftotext examples/example-onlinebrief24-signature-regression.pdf -)
if ! printf '%s' "$sig_text" | grep -F "Viele" >/dev/null; then
  printf '%s\n' "Signature regression failed: closing phrase not found in PDF." >&2
  exit 1
fi
if ! printf '%s' "$sig_text" | grep -F "Erika Mustermann" >/dev/null; then
  printf '%s\n' "Signature regression failed: signature not found in PDF." >&2
  exit 1
fi

# Extract plain text and positioned text from page 2 of the multipage regression
# PDF. The plain-text pass checks for leaked address-window content, while the
# bbox pass gives us the first text Y position on the second page.
page_two_text=$(pdftotext -f 2 -l 2 examples/example-onlinebrief24-multipage-regression.pdf -)
page_two_bbox=$(pdftotext -f 2 -l 2 -bbox examples/example-onlinebrief24-multipage-regression.pdf -)
page_two_first_ymin=$(printf '%s\n' "$page_two_bbox" | sed -n 's/.*yMin="\([0-9.]*\)".*/\1/p' | head -n 1)

# The return address must only appear in the first-page sender line.
if printf '%s' "$page_two_text" | grep -F "Erika Mustermann, Blumenweg 1, 54321 Blumenstadt" >/dev/null; then
  printf '%s\n' "Multipage regression failed: return address leaked onto page 2." >&2
  exit 1
fi

# The recipient block must also stay confined to page 1.
if printf '%s' "$page_two_text" | grep -F "Mustermann GmbH & Co. KG" >/dev/null; then
  printf '%s\n' "Multipage regression failed: recipient block leaked onto page 2." >&2
  exit 1
fi

# If bbox extraction fails, we cannot trust the layout regression result.
if [ -z "$page_two_first_ymin" ]; then
  printf '%s\n' "Multipage regression failed: could not determine page 2 text position." >&2
  exit 1
fi

# A second page should start near the normal top margin, not halfway down the
# sheet. The threshold is intentionally generous to detect regressions without
# depending on an exact font metric.
if ! awk "BEGIN { exit !($page_two_first_ymin < 120) }"; then
  printf '%s\n' "Multipage regression failed: page 2 text still starts too low (yMin=$page_two_first_ymin)." >&2
  exit 1
fi

# Print the engine in the success message so local runs and CI logs are easy
# to scan when both engines are verified in sequence.
printf '%s\n' "Verification passed for $engine."
