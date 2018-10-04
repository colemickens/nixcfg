#!/usr/bin/env bash
set -x
set -euo pipefail

export NIX_PATH=/etc/nixos:nixpkgs=/etc/nixpkgs-cmpkgs:nixos-config=/etc/nixcfg/devices/xeep/default.nix

result="$(\
  nix-build \
    --no-out-link \
    --option build-cores 0 \
    --option extra-binary-caches "https://kixstorage.blob.core.windows.net/nixcache https://cache.nixos.org https://hydra.nixos.org" \
    --option trusted-public-keys "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak= cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= hydra.nixos.org-1:CNHJZBh9K4tP3EKF6FkkgeVYsS3ohTl+oS0Qa8bezVs=" \
    -A config.system.build.toplevel \
    '<nixpkgs/nixos>')"

./az-upload-closure.sh ${result}

