#!/usr/bin/env bash
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"
set -x

cd "${DIR}"
./update-imports.sh

nix-build \
  --pure \
  --option "extra-binary-caches" "https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org" \
  --option "trusted-public-keys" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=" \
  --option "build-cores" "0" \
  --option "narinfo-cache-negative-ttl" "0" \
  --builders-use-substitutes \
  "${@}"
