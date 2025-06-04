#! /usr/bin/env bash
set -x

arrrghs=(
  --extra-experimental-features 'nix-command'
  --extra-experimental-features 'flakes'
  --option 'extra-substituters' 'https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org'
  --option 'extra-trusted-public-keys' 'colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA='
  --option 'build-cores' '0'
  --option 'narinfo-cache-negative-ttl' '0'
)

nix "${arrrghs[@]}" "${@}"
