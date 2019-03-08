#!/usr/bin/env bash

set -euo pipefail
set -x

unset NIX_PATH
unset NIXOS_CONFIG

# prove we can do day-to-day nixos operations without:
# NIX_PATH, NIXOS_CONFIG, nor `nixos-*` commands

target="$(hostname)System"
system="$(\
  nix-build \
    --option "extra-binary-caches" "https://colemickens.cachix.org" \
  -A "${target}"
)"

sudo nix-env --set \
  --profile "/nix/var/nix/profiles/system" \
  "${system}"

sudo "${system}/bin/switch-to-configuration" switch

