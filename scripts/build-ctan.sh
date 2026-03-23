#!/bin/sh
set -eu

script_dir=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
. "$script_dir/lib/common.sh"

repo_root=$(repo_root_from_dir "$script_dir")
# Extract the version date (YYYY/MM/DD) from \ProvidesClass and convert to YYYY-MM-DD.
version=$(sed -n 's/.*\\ProvidesClass{onlinebrief24}\[\([0-9/]*\).*/\1/p' "$repo_root/onlinebrief24.cls" | tr '/' '-')
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
# Keep the CTAN bundle focused on the two representative examples:
# one basic letter with the DIN-style information block and one modern
# letter with the same feature enabled.
for ex_name in example-onlinebrief24-infoblock.tex example-onlinebrief24-modern.tex; do
  ex_path="$repo_root/examples/$ex_name"
  ex=$(basename "$ex_path")
  sed 's|{../onlinebrief24}|{onlinebrief24}|' \
    "$ex_path" > "$package_root/examples/$ex"
done

# Compile example PDFs for inclusion in the CTAN package.
example_build_dir="$tmp_root/example-build"
mkdir -p "$example_build_dir"
cp "$repo_root/onlinebrief24.cls" "$example_build_dir/"
for ex_path in "$package_root"/examples/example-onlinebrief24-*.tex; do
  ex_name=$(basename "$ex_path")
  cp "$ex_path" "$example_build_dir/"
  latexmk -pdf -interaction=nonstopmode -halt-on-error \
    -outdir="$example_build_dir" "$example_build_dir/$ex_name"
  cp "$example_build_dir/${ex_name%.tex}.pdf" "$package_root/examples/"
done

# Refresh the unpacked release directory and every stale local variant from
# earlier manual experiments so `dist/ctan` contains only the current package.
find "$dist_root" -mindepth 1 -maxdepth 1 \
  \( -name 'onlinebrief24' -o -name 'onlinebrief24 *' -o -name 'onlinebrief24.zip' -o -name 'onlinebrief24-*.zip' \) \
  -exec rm -rf {} +
mv "$package_root" "$dist_root/onlinebrief24"
(cd "$dist_root" && zip -qr "onlinebrief24-${version}.zip" "onlinebrief24")

printf '%s\n' "CTAN package directory: $dist_root/onlinebrief24"
printf '%s\n' "CTAN upload archive: $dist_root/onlinebrief24-${version}.zip"
