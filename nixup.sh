#!/usr/bin/env bash

set -euo pipefail
set -x

unset NIX_PATH
unset NIXOS_CONFIG

desktop="${1:-"sway"}"
target="$(hostname)-${desktop}"
toplevel=$(./nixbuild.sh default.nix -A "${target}")

sudo nix-env --set \
  --profile "/nix/var/nix/profiles/system" \
  "${toplevel}"

sudo "${toplevel}/bin/switch-to-configuration" switch

# delete all but last few generations
echo nix-env \
  --profile "/nix/var/nix/profiles/system" \
  --delete-generations +3

#sudo nix-store --gc

sudo nix-store --optimize

