#!/usr/bin/env bash

# TODO abstract this and make /etc/nixpkgs a link to a worktree for /etc/_nixpkgs
if [[ ! -d /etc/nixpkgs ]]; then
  sudo git clone https://github.com/colemickens/nixpkgs /etc/nixpkgs
  sudo chown -R cole:cole /etc/nixpkgs
  cd /etc/nixpkgs
  sudo git worktree add /etc/nixpkgs/sway sway-wip
  sudo git worktree add /etc/nixpkgs/cmpkgs cmpkgs
  sudo git checkout kata3
fi

sudo chown -R cole:cole /etc/nixcfg
sudo chown -R cole:cole /etc/nixpkgs
sudo chown -R cole:cole /etc/nixpkgs-sway
sudo chown -R cole:cole /etc/nixpkgs-cmpkgs

sudo mkdir -p /etc/nixos/nixpkgs-mozilla
sudo chown -R cole:cole /etc/nixos/nixpkgs-mozilla
git clone https://github.com/mozilla/nixpkgs-mozilla /etc/nixos/nixpkgs-mozilla

sudo mkdir -p /etc/nixos/azure-cli-nix
sudo chown -R cole:cole /etc/nixos/azure-cli-nix
git clone https://github.com/stesie/azure-cli-nix /etc/nixos/azure-cli-nix

