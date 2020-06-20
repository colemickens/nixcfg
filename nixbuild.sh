#!/usr/bin/env bash
set -euo pipefail
set -x

# TODO: possilby move the remote builder stuff behind a flag?

nix-build \
  --pure \
  --option "extra-binary-caches" "https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org" \
  --option "trusted-public-keys" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=" \
  --option "build-cores" "0" \
  --option "narinfo-cache-negative-ttl" "0" \
  --builders-use-substitutes \
  --builders '
    ssh://root@nixos x86_64-linux' \
  "${@}"

exit 0

    ssh://colemickens@aarch64.nixos.community aarch64-linux
    ssh://cole@192.168.1.2 aarch64-linux
    ssh://cole@azdev.duckdns.org x86_64-linux
