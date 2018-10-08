#!/usr/bin/env bash

# link in the real system configuration
# rebuild the config, prep-workspace (aka, setup nixpkgs), reboot

set -x
rm -f /etc/nixos/configuration.nix
ln -s /etc/nixcfg/devices/${device}/configuration.nix /etc/nixos/configuration.nix

export NIX_PATH=nixpkgs=/etc/nixpkgs:nixos-config=/etc/nixos/configuration.nix
rb="$(nix-build --no-out-link --expr 'with import <nixpkgs/nixos> {}; config.system.build.nixos-rebuild')/bin/nixos-rebuild";
"${rb}" switch \
  --option build-cores 0 \
  --option extra-binary-caches "https://kixstorage.blob.core.windows.net/nixcache https://cache.nixos.org" \
  --option trusted-public-keys "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

/etc/nixcfg/utils/prep-workspace.sh
reboot

