#!/usr/bin/env bash
set -euo pipefail
set -x

export NIX_PATH="nixpkgs=../../../.."
export NIXOS_CONFIG="$(dirname $(readlink -f $0))/../../../modules/virtualisation/azure-image.nix"

nix-build '<nixpkgs/nixos>' \
    --attr "config.system.build.azureImage" \
    --argstr "system" "x86_64-linux" \
    --no-out-link \
    --max-jobs 16
