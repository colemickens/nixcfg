#!/usr/bin/env bash
set -x
set -euo pipefail

# TODO: for now this is hardcoded to expect a certain nixpkgs!
# that is, cmpkgs

# eventually the all.nix will specify the exact nixpkgs-{flavor} to use
# or I can paramterize this and have different sets for different nixpkgs
# (which would probably be fine because they'd probably be separate jobs anyway)

export NIX_PATH=/etc/nixos:nixpkgs=/etc/nixpkgs-cmpkgs

result="$(\
  nix-build \
    --option build-cores 0 \
    --option extra-binary-caches "https://kixstorage.blob.core.windows.net/nixcache https://cache.nixos.org" \
    --option trusted-public-keys "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" \
    "../../devices/all.nix" \
)"

echo "******* ${result}"

# TODO: IIRC this actually just uploads the entire store... lol, so it's sorta overkill, but also still needs to run always (the last "dupe" could not be and could include a closure not previously copied)
echo "${result}" | while read -r pth; do
  ./az-upload-closure.sh ${pth}
done

