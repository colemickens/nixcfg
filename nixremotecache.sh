#!/usr/bin/env bash
set -x
set -euo pipefail

remote="${1}"; shift
drv="$(nix-instantiate "${@}")"

cachixremote="colemickens"
cachixkey="$(gopass show websites/cachix.org/gh | grep "cachix_key_${cachixremote}" | cut -d' ' -f2)"

nix-copy-closure --to "ssh://${remote}" "${drv}"

ssh "${remote}" \
  "nix-build ${drv} \
    | env CACHIX_SIGNING_KEY=\"${cachixkey}\" \
      nix-shell -I 'nixpkgs=https://github.com/nixos/nixpkgs/archive/nixos-unstable.tar.gz' \
        -p cachix --command 'cachix push colemickens'"

exit 0

###############################################################################
