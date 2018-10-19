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

# clone nixpkgs
[[ ! -d /etc/nixpkgs ]] && \
	sudo git clone --bare https://github.com/colemickens/nixpkgs /etc/nixpkgs-raw

# other nixpkgs branches we use
cd /etc/nixpkgs
[[ ! -d /etc/nixpkgs-sway ]] && sudo git worktree add /etc/nixpkgs-sway sway
[[ ! -d /etc/nixpkgs-cmpkgs ]] && sudo git worktree add /etc/nixpkgs-cmpkgs cmpkgs
[[ ! -d /etc/nixpkgs-kata ]] && sudo git worktree add /etc/nixpkgs-kata kata

# make my normal user the owner
sudo chown -R 1000:1000 "/etc/nixcfg" /etc/nixpkgs*

# change into the '${device}' configuration now
export NIX_PATH=nixpkgs=/etc/nixpkgs:nixos-config=/etc/nixos/configuration.nix
rb="$(nix-build --no-out-link --expr 'with import <nixpkgs/nixos> {}; config.system.build.nixos-rebuild')/bin/nixos-rebuild";
"${rb}" boot \
  --option build-cores 0 \
  --option extra-binary-caches "https://kixstorage.blob.core.windows.net/nixcache https://cache.nixos.org" \
  --option trusted-public-keys "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

