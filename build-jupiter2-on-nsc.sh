#!/usr/bin/env bash

set -x
set -euo pipefail

remote="runner@rendezvous.namespace.so"
nixremote="ssh-ng://${remote}"

export NIX_SSHOPTS="-p 40379"
export SSH_AUTH_SOCK="/var/run/com.apple.launchd.yglq3pjw10/Listeners"

overrides=(
  --inputs-from .
  --override-input nixpkgs-riscv ~/code/nixpkgs__riscv
  --override-input determinate ~/work/code/determinate
  --override-input determinate/determinate-nixd ~/work/code/determinate-nixd
  --override-input determinate/determinate-nixd/fenix ~/work/code/fenix
  --override-input determinate/nix ~/work/code/nix-src
  --override-input determinate/nixpkgs nixpkgs-riscv
)

drv1="$(nix eval --raw "${overrides[@]}" ".#toplevels.jupitertwo.drvPath")"

nix copy --to "${nixremote}" --derivation --no-check-sigs "${drv1}"

ssh -p 40379 "${remote}" \
  nix build -L --keep-going --keep-failed --print-out-paths "'${drv1}^*'"
