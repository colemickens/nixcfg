#!/usr/bin/env bash
set -x
set -euo pipefail

device="${1:-"pktkube"}"

# clone nixcfg
[[ ! -d /etc/nixcfg ]] && sudo git clone https://github.com/colemickens/nixcfg /etc/nixcfg

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
sudo ln -s /etc/nixpkgs-kata /etc/nipkgs


# change into the '${device}' configuration now
export NIX_PATH=nixpkgs=/etc/nixpkgs:nixos-config=/etc/nixos/configuration.nix
rb="$(nix-build --no-out-link --expr 'with import <nixpkgs/nixos> {}; config.system.build.nixos-rebuild')/bin/nixos-rebuild";
"${rb}" boot \
  --option build-cores 0 \
  --option extra-binary-caches "https://kixstorage.blob.core.windows.net/nixcache https://cache.nixos.org" \
  --option trusted-public-keys "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

