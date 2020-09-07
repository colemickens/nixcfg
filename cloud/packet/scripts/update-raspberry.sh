#! /usr/bin/env bash
set -x

git config --global user.name "Cole Mickens"
git config --global user.email "cole.mickens@gmail.com"

cachix use nixpkgs-wayland
cachix use colemickens

mkdir -p ~/code

export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

if [[ ! -d ~/code/nixcfg ]]; then
  git clone https://github.com/colemickens/nixcfg ~/code/nixcfg
fi

if [[ ! -d ~/code/nixpkgs ]]; then
  git clone https://github.com/colemickens/nixpkgs ~/code/nixpkgs
  (cd ~/code/nixpkgs; git checkout rpi)
fi

(
    cd ~/code/nixcfg
    nix-shell --command "./update.sh hosts/raspberry/default.nix"
)
