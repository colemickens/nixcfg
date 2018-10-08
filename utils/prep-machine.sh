#!/usr/bin/env bash

set -x

if [[ ! -f "/etc/nixos/configuration-original.nix" ]]; then
  mv /etc/nixos/configuration.nix "/etc/nixos/configuration-original.nix" || true
fi
rm -f /etc/nixos/configuration.nix
ln -s /etc/nixcfg/devices/${device}/configuration.nix /etc/nixos/configuration.nix

# TODO: move to packet-kube/config (?)
cat <<EOF >/root/.gitconfig
[user]
  email = cole.mickens@gmail.com
  name = Cole Mickens
EOF

export NIX_PATH=nixpkgs=/etc/nixpkgs:nixos-config=/etc/nixos/configuration.nix
export NIXOSRB="$(nix-instantiate --eval -E '<nixpkgs>')/nixos/modules/installer/tools/nixos-rebuild.sh"
export NIXOSRB="$(nix-build --no-out-link --expr 'with import <nixpkgs/nixos> {}; config.system.build.nixos-rebuild')/bin/nixos-rebuild";
"''${NIXOSRB}" switch \
  --option extra-binary-caches \
  "https://kixstorage.blob.core.windows.net/nixcache https://cache.nixos.org" \
  --option trusted-public-keys \
  "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

/etc/nixcfg/utils/prep-workspace.sh

reboot

