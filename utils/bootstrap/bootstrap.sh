#!/usr/bin/env bash
set -x
set -euo pipefail

device="${1:-"pktkube"}"
nixcfg="/etc/nixcfg"

# clone nixcfg
if [[ ! -d "${nixcfg}" ]]; then
  sudo git clone https://github.com/colemickens/nixcfg /etc/nixcfg
fi

# link nixos config
mv /etc/nixos/configuration.nix "/etc/nixos/configuration-old-$(date '+%s').nix" || true
ln -s "${nixcfg}/modules/config-${device}.nix" /etc/nixos/configuration.nix

# make my normal user the owner
sudo chown -R 1000:1000 "${nixcfg}"

## Bootstrap the nixpkgs branches, etc
"${nixcfg}/utils/bootstrap/bootstrap-nixpkgs.sh"

# we still need to assume /etc/nixpkgs is the system config
# for now bootstrap.sh is specific to the nixos device "pktkube" w/ nixpkgs branch "kata"
if [[ ! -e /etc/nixpkgs ]]; then
  sudo ln -s /etc/nixpkgs-kata /etc/nixpkgs
fi

# change into the '${device}' configuration now
"${nixcfg}/utils/azure/nix-build.sh" "${nixcfg}/default.nix" -A "${device}"

export NIX_PATH=nixpkgs=/etc/nixpkgs:nixos-config=/etc/nixos/configuration.nix
rb="$(nix-build --no-out-link --expr 'with import <nixpkgs/nixos> {}; config.system.build.nixos-rebuild')/bin/nixos-rebuild";
sudo -E "${rb}" boot

