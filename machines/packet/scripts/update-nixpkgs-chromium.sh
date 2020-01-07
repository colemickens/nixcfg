#! /usr/bin/env bash
set -x

git config --global user.name "Cole Mickens"
git config --global user.email "cole.mickens@gmail.com"

cachix use nixpkgs-wayland
mkdir -p ~/code/overlays

export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

[[ ! -d ~/code/overlays/nixpkgs-chromium ]] \
    && git clone https://github.com/colemickens/nixpkgs-chromium ~/code/overlays/nixpkgs-chromium

(
    cd ~/code/overlays/nixpkgs-chromium
    nix-shell --command "./update.sh"
)
