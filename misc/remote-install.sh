#!/usr/bin/env bash
set -x

remote="$1"; shift
top="$1"; shift

if [[ "${remote}" == "xx" ]]; then
  sudo nix-store -vv --store /mnt -r \
    --option narinfo-cache-negative-ttl 0 \
    --option extra-substituters 'https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org' \
    --option extra-trusted-public-keys 'colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=' \
    "${top}"
  sudo nixos-install \
    --option extra-substituters 'https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org' \
    --option extra-trusted-public-keys 'colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=' \
    --root /mnt \
    --system "${top}"
else
  scp "$0" "cole@${remote}:/tmp/install.sh"
  ssh "cole@${remote}" "/tmp/install.sh xx ${top}"
fi
