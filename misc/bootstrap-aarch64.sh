#!/usr/bin/env bash

set -x
set -euo pipefail

host="colemickens@aarch64.nixos.community"

ssh $host \
  "true; \
    mkdir -p ~/code/; \
    mkdir -p ~/.config/cachix/; \
    nix profile install \
      nixpkgs#helix \
      nixpkgs#cachix \
      nixpkgs#bottom \
      nixpkgs#git \
      nixpkgs#ripgrep \
      nixpkgs#rsync \
      nixpkgs#zellij
  "

if ! ssh "${host}" "ls ~/.config/cachix/cachix.dhall"; then
  scp "${HOME}/.config/cachix/cachix.dhall" \
    "${host}:~/.config/cachix/cachix.dhall"
fi

dir="~/code"
rsync -avh --delete \
  ~/code/nixos-snapdragon-elite \
  ~/code/h96-max-v58-nixos \
  ~/code/nixpkgs \
  ~/code/nixcfg \
  $host:$dir
