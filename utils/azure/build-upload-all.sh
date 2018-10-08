#!/usr/bin/env bash
set -x
set -euo pipefail

result="$(\
  nix-build \
    --option build-cores 0 \
    --option extra-binary-caches "https://kixstorage.blob.core.windows.net/nixcache https://cache.nixos.org" \
    --option trusted-public-keys "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" \
    "../../devices/all.nix" \
)"

echo "${result}" | while read -r pth; do
  ./az-upload-closure.sh ${pth}
done

