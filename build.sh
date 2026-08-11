#!/usr/bin/env bash

set -x
set -euo pipefail

remote="cole@jupitertwo"
nixremote="ssh-ng://cole@jupitertwo"

export SSH_AUTH_SOCK="/var/run/com.apple.launchd.7mZ89cs5gV/Listeners"

overrides=(
  --inputs-from .
  # --override-input nixpkgs-riscv ~/code/nixpkgs
  --override-input determinate ~/work/code/determinate
  --override-input determinate/determinate-nixd ~/work/code/determinate-nixd
  --override-input determinate/determinate-nixd/fenix ~/work/code/fenix
  --override-input determinate/nix ~/work/code/nix-src
  --override-input determinate/nixpkgs ~/code/nixpkgs
)
thing=".#toplevels.jupitertwo-native"

nix copy --to "${nixremote}" --derivation --no-check-sigs "${thing}.drvPath"
# ssh "${remote}" nix build -L --keep-going --print-out-paths "${things}^*"

### OPTION 1 (this is sooo frustrating, the server/client auth stuff is so limiting)
# nix build -L --keep-going --keep-failed --print-out-paths -j0 \
#   --builders "${nixremote} riscv64-linux" \
#   "${overrides[@]}" "${things[@]}"
# exit 0

### OPTION 2 (doesn't --keep-building)
# nix build -L --keep-going --eval-store auto -vvv \
#   --store "${nixremote}" \
#   "${overrides[@]}" "${things[@]}"
# exit 0

### OPTION 3 (yay, lol)
# note: you can't `nix copy .drvPath --derivation` because it ALSO complains!!
# one="$(nix eval --raw "${overrides[@]}" ".#packages.riscv64-linux.determinate-nix-cli.drvPath")"
# two="$(nix eval --raw "${overrides[@]}" ".#packages.riscv64-linux.determinate-nixd.drvPath")"
# tre="$(nix eval --raw "${overrides[@]}" ".#packages.riscv64-linux.magic-nix-cache.drvPath")"

# nix copy --to "${nixremote}" --derivation --no-check-sigs \
#   "${one}" \
#   "${two}" \
#   "${tre}"

# nix build -L --keep-going --keep-failed --print-out-paths \
#   "${one}^*" "${two}^*" "${tre}^*"
