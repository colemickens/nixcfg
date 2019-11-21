#! /usr/bin/env bash
set -x

[[ "${HOSTNAME}" == "xeep" ]] && exit 0

git config --global user.name "Cole Mickens"
git config --global user.email "cole.mickens@gmail.com"

cachix use nixpkgs-wayland
cachix use colemickens

mkdir -p ~/code

export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"

[[ ! -d ~/code/nixpkgs ]] \
    && git clone https://github.com/colemickens/nixpkgs ~/code/nixpkgs
(cd ~/code/nixpkgs;
    git remote add nixpkgs https://github.com/nixos/nixpkgs || true;
    git remote update
    git reset --hard origin/cmpkgs
)

[[ ! -d ~/code/nixcfg ]] \
    && git clone https://github.com/colemickens/nixcfg ~/code/nixcfg
(cd ~/code/nixcfg;
    git remote update
    git reset --hard origin/master
    ./update.sh
)