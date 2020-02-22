#!/usr/bin/env bash

nix-build \
  --pure \
  --option "extra-binary-caches" "https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org" \
  --option "trusted-public-keys" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:oIGbn9aolUT2qKqC78scPcDL6nz7Npgotu644V4aGl4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=" \
  --option "build-cores" "0" \
  --option "narinfo-cache-negative-ttl" "0" \
  "${@}"

exit 0

# yay, ulimit because of <insert link to issue on 'nix' about regex being slow>

# todo. better way to do this, I wonder if you can exploit by changing file
#   after this program starts?
# todo2: im so sick of bash, is "${@}" even properly quoted below?
#   does it ever even actually matter? attr args could have spaces though...
set -x
if [[ "$1" == "run" ]]; then
  shift
  nix-build \
    --pure \
    --option "extra-binary-caches" "https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org" \
    --option "trusted-public-keys" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:oIGbn9aolUT2qKqC78scPcDL6nz7Npgotu644V4aGl4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=" \
    --option "build-cores" "0" \
    --option "narinfo-cache-negative-ttl" "0" \
    "${@}"
else
  sudo bash -c "ulimit 100000; $(readlink -f "${0}") run ${@}"; echo "done";
fi
