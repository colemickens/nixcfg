#!/usr/bin/env bash
set -x
set -euo pipefail

d="${HOME}/code/nixpkgs/cmpkgs/nixos/maintainers/scripts/azure-new"
img_id="$("${d}/upload-image.sh" ./image-azdev.nix)"
"${d}/boot-vm.sh" "${img_id}"
