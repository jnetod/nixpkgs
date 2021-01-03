#!/usr/bin/env nix-shell
#!nix-shell --pure -p nix git gnumake cacert -i bash

# naive script to (help to) update deps.nix
# usage:
#   - ./update-deps.sh <pname> > deps_updated.nix; mv deps_updated.nix deps.nix
#   - or, with sponge from moreutils: ./update-deps.sh <pname> | sponge deps.nix

set -euo pipefail
IFS=$'\n\t'

package_name="$1"
nixpkgs_git_root=$(git rev-parse --show-toplevel)
temp_dir=$(mktemp -d)
cd "$temp_dir"
nix-shell -E "with import $nixpkgs_git_root {}; $package_name" --run unpackPhase > /dev/null 2>&1
unpacked_src=$(ls)
cd "$unpacked_src"/src
deps=$(make -n deps | grep -Eo "(http|https)://[a-zA-Z0-9./~?=_%:-]*")
TAB="  "
echo "{"
for url in $deps; do
  name=$(basename "$url")
  checksum=$(nix-prefetch-url "$url" 2> /dev/null)

  echo "${TAB}\"$name\" = {"
  echo "${TAB}${TAB}url = \"$url\";"
  echo "${TAB}${TAB}sha256 = \"$checksum\";"
  echo "${TAB}};"
done
echo "}"
rm -rf "$temp_dir"