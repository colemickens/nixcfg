#!/usr/bin/env bash
set -x
set -euo pipefail

unset NIX_PATH
unset NIXOS_CONFIG

f="${1:-"../default.nix"}"

results="$(\
  nix-build \
    --no-out-link \
    --option build-cores 0 \
    --option extra-binary-caches "https://nixcache.cluster.lol https://cache.nixos.org" \
    --option trusted-public-keys "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" \
    "${nixfiletobuild}")"

echo "${results}" | while read -r closure; do
  ${nixcfg}/utils/nix/cache-closure.sh "${closure}"
done

${nixcfg}/utils/azure/upload-cache.sh

