#!/bin/sh
set -eu

repo_root=$(CDPATH= cd -- "$(dirname -- "$0")/.." && pwd)
ctan_src_dir="$repo_root/ctan"
build_root="$repo_root/dist"
dist_root="$repo_root/dist/ctan"
mkdir -p "$build_root"
tmp_root=$(mktemp -d "$build_root/ctan-stage.XXXXXX")
package_root="$tmp_root/onlinebrief24"
doc_build_dir="$tmp_root/doc-build"

trap 'rm -rf "$tmp_root"' EXIT INT TERM

mkdir -p "$dist_root" "$package_root" "$package_root/examples" "$doc_build_dir"

# Build the English CTAN documentation outside the tracked working tree so
# auxiliary files and the generated PDF stay confined to dist/.
latexmk -pdf -interaction=nonstopmode -halt-on-error \
  -outdir="$doc_build_dir" "$ctan_src_dir/onlinebrief24-doc.tex"

# Assemble the package payload with only the files intended for CTAN.
cp "$repo_root/onlinebrief24.cls" "$package_root/"
cp "$repo_root/LICENSE" "$package_root/"
cp "$ctan_src_dir/README.md" "$package_root/README"
cp "$ctan_src_dir/onlinebrief24-doc.tex" "$package_root/"
cp "$doc_build_dir/onlinebrief24-doc.pdf" "$package_root/"
cp "$repo_root/examples/example-basic.tex" "$package_root/examples/"
cp "$repo_root/examples/example-modern.tex" "$package_root/examples/"

# Refresh the unpacked release directory and the upload archive.
rm -rf "$dist_root/onlinebrief24" "$dist_root/onlinebrief24.zip"
mv "$package_root" "$dist_root/onlinebrief24"
(cd "$dist_root" && zip -qr "onlinebrief24.zip" "onlinebrief24")

printf '%s\n' "CTAN package directory: $dist_root/onlinebrief24"
printf '%s\n' "CTAN upload archive: $dist_root/onlinebrief24.zip"
