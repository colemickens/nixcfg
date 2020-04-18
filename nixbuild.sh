#!/usr/bin/env bash
set -euo pipefail
set -x

# TODO: possilby move the remote builder stuff behind a flag?

nix-build \
  --pure \
  --option "extra-binary-caches" "https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org" \
  --option "trusted-public-keys" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:oIGbn9aolUT2qKqC78scPcDL6nz7Npgotu644V4aGl4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=" \
  --option "build-cores" "0" \
  --builders '
    ssh://colemickens@aarch64.nixos.community aarch64-linux /home/cole/.ssh/id_ed25519;' \
  --option "narinfo-cache-negative-ttl" "0" \
  --builders-use-substitutes \
  "${@}"

exit 0

  --builders '
    ssh://colemickens@aarch64.nixos.community aarch64-linux /home/cole/.ssh/id_ed25519;
    ssh://cole@azdev.westus2.cloudapp.azure.com x86_64-linux /home/cole/.ssh/id_ed25519 - - big-parallel' \
