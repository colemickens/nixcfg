#!/usr/bin/env bash
set -x
set -euo pipefail

remote="${1}"; shift
drv="$(nix-instantiate "${@}")"

C="colemickens"
cachixkey="$(gopass show "websites/cachix.org/apikey/${C}")"

nix-copy-closure --to "ssh://${remote}" "${drv}"

ssh "${remote}" \
  "nix-build \
  --pure \
  --option \"extra-binary-caches\" \"https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org\" \
  --option \"trusted-public-keys\" \"cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=\" \
  --option \"build-cores\" \"0\" \
  --option \"narinfo-cache-negative-ttl\" \"0\" \
  ${drv} --keep-going \
    | env CACHIX_SIGNING_KEY=\"${cachixkey}\" \
      nix-shell -I 'nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz' \
        -p cachix --command 'cachix push colemickens'"

exit 0

###############################################################################
