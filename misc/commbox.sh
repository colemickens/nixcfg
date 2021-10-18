#! /usr/bin/env bash
set -euo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/stderr 2>&1 && pwd )"
cd "${DIR}"

ssh "colemickens@aarch64.nixos.community" \
  "nix-env -f /run/current-system/nixpkgs -iA \
    git zellij nixUnstable htop ncdu file nix-stop ncdu neovim cachix; \
  mkdir -p /home/colemickens/.config/cachix"

scp "${HOME}/.config/cachix/cachix.dhall" "colemickens@aarch64.nixos.community:/home/colemickens/.config/cachix/cachix.dhall"
