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

## this is remote build stuff I need for pi but it eneds to be reconciled
# with nixremotecache.sh
elif true; then
  toplevel="$(./scripts/nixbuild.sh "./machines/${machinename}")"
  NIX_SSHOPTS="-p ${port}" nix-copy-closure --to "ssh://${remote}" "${toplevel}"
  ssh "${remote}" -p "${port}" "\
    sudo bash -c \" nix-env --set --profile /nix/var/nix/profiles/system ${toplevel} \
    && ${toplevel}/bin/switch-to-configuration switch\""

else
  drv="$(nix-instantiate "./machines/${machinename}")"

  #cachixremote="colemickens"
  #cachixkey="$(gopass show websites/cachix.org/gh | grep "cachix_key_${cachixremote}" | cut -d' ' -f2)"

  nix-copy-closure --to "ssh://${remote}" "${drv}"

  ssh "${remote}" \
    "nix-build -j1 ${drv}"

  ssh "${remote}" -p "${port}" "\
    sudo bash -c \" nix-env --set --profile /nix/var/nix/profiles/system ${toplevel} \
    && ${toplevel}/bin/switch-to-configuration switch\""
fi

