#!/usr/bin/env bash

set -x
set -euo pipefail

ssh "colemickens@aarch64.nixos.community" \
  "mkdir -p ~/.config/cachix/; \
    nix profile install \
      nixpkgs#helix \
      nixpkgs#bottom \
      nixpkgs#git \
      nixpkgs#rsync \
      nixpkgs#zellij \
  "

scp "$HOME/.config/cachix/cachix.dhall" \
  "colemickens@aarch64.nixos.community:~/.config/cachix/cachix.dhall"
