#!/usr/bin/env bash

# TODO: need to have cachix signatures in here
# otherwise substituting bails on bad signatures
# and we rebuild way more than we probably need to otherwise

exec nix-build \
  --option "extra-binary-caches" "https://cache.nixos.org" \
  --option "extra-binary-caches" "https://colemickens.cachix.org" \
  --option "extra-binary-caches" "https://nixpkgs-wayland.cachix.org" \
  --option "trusted-public-keys" "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" \
  --option "trusted-public-keys" "colemickens.cachix.org-1:oIGbn9aolUT2qKqC78scPcDL6nz7Npgotu644V4aGl4=" \
  --option "trusted-public-keys" "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=" \
  --option "build-cores" "0" \
  "${@}"
