#!/usr/bin/env bash

set -x
set -euo pipefail

nix build .#extra.aarch64-linux.h96maxv58-image-builder \
  --keep-going \
  --override-input h96 ~/code/h96-max-v58-nixos \
  --override-input cmpkgs ~/code/nixpkgs \
  --out-link ~/result-h96maxv58-image-builder \
  --print-out-paths \
    | cachix push colemickens
