#!/usr/bin/env bash
set -x
set -euo pipefail

device="${1:-"pktkube"}"
branch="${2:-"kata"}"
root="/etc/nixcfg"

# clone root
[[ ! -d "${root}" ]] && sudo \
  git clone https://github.com/colemickens/nixcfg "${root}" /etc/root

# link nixos config
mv /etc/nixos/{configuration.nix,configuration-old-$(date '+%s').nix} || true
ln -s "${root}/modules/config-${device}.nix" /etc/nixos/configuration.nix

# make my normal user the owner
sudo chown -R 1000:1000 "${root}"

## Bootstrap the nixpkgs branches, etc
"${root}/utils/bootstrap/bootstrap-nixpkgs.sh"

# make the right branch the active nixpkgs
sudo ln -s "/etc/nixpkgs-${branch}" /etc/nixpkgs || true

# activate our cache
cachix use
nix-env -iA cachix -f https://github.com/NixOS/nixpkgs/tarball/889c72032
cachix use colemickens

# build this devices configuration
nix build "${root}/default.nix" -A "${device}"

# set NIX_PATH, find nixos-rebuild, call it
export NIX_PATH=nixpkgs=/etc/nixpkgs:nixos-config=/etc/nixos/configuration.nix
rb="$(nix-build --no-out-link --expr 'with import <nixpkgs/nixos> {}; config.system.build.nixos-rebuild')/bin/nixos-rebuild";
sudo -E "${rb}" boot

