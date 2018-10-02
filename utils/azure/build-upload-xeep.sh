#!/usr/bin/env bash
set -x

export NIX_PATH=/etc/nixos:nixpkgs=/etc/nixpkgs-cmpkgs:nixos-config=/etc/nixcfg/devices/xeep/default.nix
result="$(nix-build --no-out-link -A config.system.build.toplevel '<nixpkgs/nixos>')"

./az-upload-closure.sh ${result}

