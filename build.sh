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
  --override-input determinate/nixpkgs nixpkgs-riscv
)
thing=".#toplevels.jupitertwo-native"

drv="$(nix eval "${overrides[@]}" --raw "${thing}.drvPath")"
nix copy --to "${nixremote}" --derivation --no-check-sigs "${drv}"

ssh "${remote}" nix-build --dry-run "${drv}"
exit 0

ssh "${remote}" <<EOF
  zellij attach --create-background jupitertwo
  echo "layout { pane command=\"nix\" { args \"build\" \"-L\" \"--keep-going\" \"--keep-failed\" \"--print-out-paths\" \"-j2\" \"${drv}^*\"; }; }" >/tmp/task.kdl
  zellij --session jupitertwo action new-tab --layout /tmp/task.kdl
EOF
