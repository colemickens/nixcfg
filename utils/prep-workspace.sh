#!/usr/bin/env bash

sudo mkdir -p /etc/nixpkgs-sway
sudo mkdir -p /etc/nixpkgs-cmpkgs

sudo chown -R cole:cole /etc/nixcfg
sudo chown -R cole:cole /etc/nixpkgs
sudo chown -R cole:cole /etc/nixpkgs-sway
sudo chown -R cole:cole /etc/nixpkgs-cmpkgs

cd /etc/nixpkgs
git worktree add ../nixpkgs-sway sway-wip
git worktree add ../nixpkgs-cmpkgs cmpkgs

sudo mkdir -p /etc/nixos/nixpkgs-mozilla
sudo chown -R cole:cole /etc/nixos/nixpkgs-mozilla
git clone https://github.com/mozilla/nixpkgs-mozilla /etc/nixos/nixpkgs-mozilla

