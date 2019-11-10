#!/usr/bin/env bash

set -x
set -euo pipefail

rm -rf ~/.config/cachix
mkdir -p ~/.config/cachix
cp "${cachixFile}" ~/.config/cachix/cachix.dhall

git config --global user.name "Cole Mickens"
git config --global user.email "cole.mickens@gmail.com"

cachix use nixpkgs-wayland
cachix use colemickens

mkdir -p ~/code/overlays

export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
[[ ! -d ~/code/nixcfg ]] \
    && git clone https://github.com/colemickens/nixcfg ~/code/nixcfg
[[ ! -d ~/code/nixpkgs ]] \
    && git clone https://github.com/colemickens/nixpkgs ~/code/nixpkgs
[[ ! -d ~/code/overlays/nixpkgs-wayland ]] \
    && git clone https://github.com/colemickens/nixpkgs-wayland ~/code/overlays/nixpkgs-wayland

(cd ~/code/nixpkgs;
    #git remote add nixpkgs https://github.com/nixos/nixpkgs || true;
    #git remote add nixpkgs-channels https://github.com/nixos/nixpkgs-channels || true;
    git remote update
    git reset --hard origin/cmpkgs
)

(cd ~/code/overlays/nixpkgs-wayland;
    git remote update
    git reset --hard origin/master
    ./update.sh
)

(cd ~/code/nixcfg;
    git remote update
    git reset --hard origin/master
    ./update.sh
)