#!/usr/bin/env bash

# Clone nixpkgs
# setup the other branches of nixpkgs, and the overlays we use

set -x
[[ ! -d /etc/nixpkgs ]] && sudo git clone https://github.com/colemickens/nixpkgs /etc/nixpkgs -b kata3

cd /etc/nixpkgs
[[ ! -d /etc/nixpkgs-sway ]] && sudo git worktree add /etc/nixpkgs-sway sway-wip
[[ ! -d /etc/nixpkgs-cmpkgs ]] && sudo git worktree add /etc/nixpkgs-cmpkgs cmpkgs

sudo mkdir -p /etc/nixos/nixpkgs-mozilla
sudo git clone https://github.com/mozilla/nixpkgs-mozilla /etc/nixos/nixpkgs-mozilla

sudo mkdir -p /etc/nixos/azure-cli-nix
sudo git clone https://github.com/stesie/azure-cli-nix /etc/nixos/azure-cli-nix

sudo chown -R cole:cole /etc/nixcfg
sudo chown -R cole:cole /etc/nixpkgs*
sudo chown -R cole:cole /etc/nixos/nixpkgs-mozilla
sudo chown -R cole:cole /etc/nixos/azure-cli-nix

