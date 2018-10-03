#!/usr/bin/env bash

sudo mkdir -p /etc/nixpkgs-sway
sudo mkdir -p /etc/nixpkgs-cmpkgs
sudo mkdir -p /etc/nixpkgs-kata3
sudo ln -s /etc/nixpkgs-kata3 /etc/nixpkgs

sudo chown -R cole:cole /etc/nixpkgs-sway
sudo chown -R cole:cole /etc/nixpkgs-cmpkgs
sudo chown -R cole:cole /etc/nixpkgs-kata3

git clone https://github.com/colemickens/nixpkgs /etc/nixpkgs-cmpkgs
cd /etc/nixpkgs-cmpkgs
git worktree add ../nixpkgs-sway sway-wip
git worktree add ../nixpkgs-kata3 kata3

