#!/usr/bin/env bash

exec nix-build \
  --option "extra-binary-caches" "https://colemickens.cachix.org" \
  --option "extra-binary-caches" "https://nixpkgs-wayland.cachix.org" \
  "${@}"
