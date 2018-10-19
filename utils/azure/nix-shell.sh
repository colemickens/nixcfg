#!/usr/bin/env bash
set -x
set -euo pipefail

unset NIX_PATH
unset NIXOS_CONFIG
nixcfg="/etc/nixcfg"

# how to use an overlay with nix-shell?
nix-shell -p "python36packages.azure-cli"

