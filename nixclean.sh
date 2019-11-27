#!/usr/bin/env bash
set -euo pipefail
set -x

unset NIX_PATH
unset NIXOS_CONFIG

nix-env \
  --profile "/nix/var/nix/profiles/system" \
  --delete-generations +3

sudo nix-store --gc

sudo nix-store --optimize

