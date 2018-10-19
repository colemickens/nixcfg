#!/usr/bin/env bash
set -x
set -euo pipefail

device="${1:-"pktkube"}"

# clone nixcfg
if [[ ! -d "${nixcfg}" ]]; then
  sudo git clone https://github.com/colemickens/nixcfg /etc/nixcfg
fi
(cd /etc/nixcfg; sudo git remote update; sudo git reset --hard origin/master;)

# link nixos config
mv /etc/nixos/configuration.nix "/etc/nixos/configuration-old-$(date '+%s').nix" || true
ln -s "/etc/nixcfg/modules/config-${device}.nix" /etc/nixos/configuration.nix

# make my normal user the owner
sudo chown -R 1000:1000 "/etc/nixcfg"

## Bootstrap the nixpkgs branches, etc
./bootstrap-nixpkgs.sh

# we still need to assume /etc/nixpkgs is the system config
# for now bootstrap.sh is specific to the nixos device "pktkube" w/ nixpkgs branch "kata"
sudo ln -s /etc/nixpkgs /etc/nixpkgs-kata


# change into the '${device}' configuration now
"${nixcfg}/utils/azure/nix-build.sh" -A "system.config.build.toplevel"

export NIX_PATH=nixpkgs=/etc/nixpkgs:nixos-config=/etc/nixos/configuration.nix
sudo -E nixos-rebuild boot

