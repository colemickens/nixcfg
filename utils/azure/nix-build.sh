#!/usr/bin/env bash
set -x
set -euo pipefail

results="$(\
  nix-build \
    --show-trace \
    --no-out-link \
    --option build-cores 0 \
    --option extra-binary-caches "https://nixcache.cluster.lol https://cache.nixos.org" \
    --option trusted-public-keys "nixcache.cluster.lol-1:DzcbPT+vsJ5LdN1WjWxJPmu+BeU891mgsrRa2X+95XM= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" \
    "${@}")"

exit 0

