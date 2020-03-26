#!/usr/bin/env bash
set -euo pipefail
set -x

#(
#  cd ~/code/nixpkgs
#  git remote update
#  git rebase nixpkgs/nixos-unstable
#)

# 1. use ./nixbuild.sh first so that we get caching benefits
#    even on a blank system
# 2. we're back to using <nixpkgs/nixos> because my other methods seem
#    to result in a lot of copies of nixpkgs being copied into the store.

export NIX_PATH=nixpkgs=/home/cole/code/nixpkgs:nixos-config=/home/cole/code/nixcfg/machines/slynux/sway.nix
./nixbuild.sh '<nixpkgs/nixos>' -A config.system.build.toplevel

# we might still need ulimit
sudo bash -c "ulimit -s 100000; nixos-rebuild switch"
