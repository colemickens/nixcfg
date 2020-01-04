#!/usr/bin/env bash
set -euo pipefail
set -x

unset NIX_PATH
unset NIXOS_CONFIG

desktop="${1:-"sway"}"
target="${1:-"$(hostname)-${desktop}"}"
toplevel=$(./nixbuild.sh default.nix -A "${target}")

sudo nix-env --set \
  --profile "/nix/var/nix/profiles/system" \
  "${toplevel}"

sudo "${toplevel}/bin/switch-to-configuration" switch
