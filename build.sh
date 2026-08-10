#!/usr/bin/env bash

set -x
set -euo pipefail

remote="cole@jupitertwo"
nixremote="ssh-ng://cole@jupitertwo"

export SSH_AUTH_SOCK="/var/run/com.apple.launchd.7mZ89cs5gV/Listeners"

overrides=(
  --override-input cmpkgs ~/code/nixpkgs
  --override-input determinate ~/work/code/determinate
  --override-input determinate/nix ~/work/code/nix-src
  --override-input determinate/nixpkgs ~/code/nixpkgs
)

# thing="$(nix eval --raw "${overrides[@]}" ".#toplevels.jupitertwo-native.drvPath")"
# nix copy --to "${nixremote}" --derivation --no-check-sigs "${thing}"
# ssh "${remote}" nix build -L --keep-going --print-out-paths "${thing}^*"

nix build -L --keep-going "${overrides[@]}" ".#toplevels.jupitertwo-cross"
