#!/usr/bin/env bash
set -euo pipefail
set -x

unset NIX_PATH
unset NIXOS_CONFIG

desktop="${1:-"sway"}"
target="${1:-"$(hostname)-${desktop}"}"
#toplevel=$(./nixbuild.sh default.nix -A "${target}")

sudo env NIX_PATH=nixpkgs=/home/cole/code/nixpkgs:nixos-config=/etc/nixos/configuration.nix \
  nixos-rebuild switch

