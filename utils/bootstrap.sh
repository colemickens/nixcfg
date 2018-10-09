#!/usr/bin/env bash
set -x
set -euo pipefail

device="${1:-"packet-kube"}"

# clone nixpkgs
[[ ! -d /etc/nixcfg ]] && sudo git clone https://github.com/colemickens/nixcfg /etc/nixcfg -b kata3
[[ ! -d /etc/nixpkgs ]] && sudo git clone https://github.com/colemickens/nixpkgs /etc/nixpkgs -b kata3
(cd /etc/nixcfg; sudo git remote update; sudo git reset --hard origin/master;)

# link nixos config
mv /etc/nixos/configuration.nix "/etc/nixos/configuration-old-$(date '+%s').nix" || true
ln -s /etc/nixcfg/devices/${device}/configuration.nix /etc/nixos/configuration.nix

# other nixpkgs branches we use
cd /etc/nixpkgs
[[ ! -d /etc/nixpkgs-sway ]] && sudo git worktree add /etc/nixpkgs-sway sway-wip
[[ ! -d /etc/nixpkgs-cmpkgs ]] && sudo git worktree add /etc/nixpkgs-cmpkgs cmpkgs
# overlays
[[ ! -d /etc/nixos/azure-cli-nix ]] && sudo git clone https://github.com/stesie/azure-cli-nix /etc/nixos/azure-cli-nix
[[ ! -d /etc/nixos/nixpkgs-mozilla ]] && sudo git clone https://github.com/mozilla/nixpkgs-mozilla /etc/nixos/nixpkgs-mozilla

# make my normal user the owner
sudo chown -R 1000:1000 "/etc/nixcfg" /etc/nixpkgs* "/etc/nixos/nixpkgs-mozilla" "/etc/nixos/azure-cli-nix"

# change into the '${device}' configuration now
export NIX_PATH=nixpkgs=/etc/nixpkgs:nixos-config=/etc/nixos/configuration.nix
rb="$(nix-build --no-out-link --expr 'with import <nixpkgs/nixos> {}; config.system.build.nixos-rebuild')/bin/nixos-rebuild";
"${rb}" boot \
  --option build-cores 0 \
  --option extra-binary-caches "https://kixstorage.blob.core.windows.net/nixcache https://cache.nixos.org" \
  --option trusted-public-keys "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

reboot

