#!/usr/bin/env bash
set -x

device="${1:-"packet-kube"}"

# clone nixcfg, link nixos config
[[ ! -d /etc/nixcfg ]] && sudo git clone https://github.com/colemickens/nixcfg /etc/nixcfg
mv /etc/nixos/configuration.nix "/etc/nixos/configuration-old-$(date '+%s').nix" || true
ln -s /etc/nixcfg/devices/${device}/configuration.nix /etc/nixos/configuration.nix

# change into the '${device}' configuration now
export NIX_PATH=nixpkgs=/etc/nixpkgs:nixos-config=/etc/nixos/configuration.nix
rb="$(nix-build --no-out-link --expr 'with import <nixpkgs/nixos> {}; config.system.build.nixos-rebuild')/bin/nixos-rebuild";
"${rb}" switch \
  --option build-cores 0 \
  --option extra-binary-caches "https://kixstorage.blob.core.windows.net/nixcache https://cache.nixos.org" \
  --option trusted-public-keys "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

# clone nixpkgs
[[ ! -d /etc/nixpkgs ]] && sudo git clone https://github.com/colemickens/nixpkgs /etc/nixpkgs -b kata3
# other nixpkgs branches we use
cd /etc/nixpkgs
[[ ! -d /etc/nixpkgs-sway ]] && sudo git worktree add /etc/nixpkgs-sway sway-wip
[[ ! -d /etc/nixpkgs-cmpkgs ]] && sudo git worktree add /etc/nixpkgs-cmpkgs cmpkgs
# overlays
[[ ! -d /etc/nixos/azure-cli-nix ]] && sudo git clone https://github.com/stesie/azure-cli-nix /etc/nixos/azure-cli-nix
[[ ! -d /etc/nixos/nixpkgs-mozilla ]] && sudo git clone https://github.com/mozilla/nixpkgs-mozilla /etc/nixos/nixpkgs-mozilla

sudo chown -R cole:cole /etc/nixcfg
sudo chown -R cole:cole /etc/nixpkgs*
sudo chown -R cole:cole /etc/nixos/nixpkgs-mozilla
sudo chown -R cole:cole /etc/nixos/azure-cli-nix

sleep 120
reboot
