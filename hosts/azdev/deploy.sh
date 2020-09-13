#!/usr/bin/env bash
set -x
set -euo pipefail

nix build \
  --out-link /tmp/azdev \
  --override-input nixpkgs "/home/cole/code/nixpkgs/cmpkgs" \
  --override-input firefox "/home/cole/code/flake-firefox-nightly" \
  --override-input sops-nix "/home/cole/code/sops-nix" \
  --override-input home-manager "/home/cole/code/home-manager/cmhm" \
  --override-input mobile-nixos "/home/cole/code/mobile-nixos" \
  --override-input nixpkgs-wayland "/home/cole/code/nixpkgs-wayland" \
  --override-input wip-pinebook-pro "/home/cole/code/wip-pinebook-pro" \
  --override-input nixos-veloren "/home/cole/code/nixos-veloren" \
  --override-input nixos-azure "/home/cole/code/nixos-azure" \
  "../..#hosts.azdev"

d="${HOME}/code/nixos-azure/scripts"

# -> nixos-azure/scripts/upload-image.sh /tmp/azdev
# -> nixos-azure/scripts/boot-image.sh

img_id="$("${d}/upload-image.sh" "/tmp/azdev")"
"${d}/boot-vm.sh" "${img_id}"
