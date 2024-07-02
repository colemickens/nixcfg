#!/usr/bin/env nu

let stashdir = "/var/lib/github-stash"
sudo rm -rf $"($stashdir)/nixpkgs"
sudo cp -a /home/cole/code/nixpkgs $"($stashdir)/nixpkgs_"
sudo mv $"($stashdir)/nixpkgs_" $"($stashdir)/nixpkgs"

sudo rm -rf $"($stashdir)/home-manager"
sudo cp -a /home/cole/code/home-manager $"($stashdir)/home-manager_"
sudo mv $"($stashdir)/home-manager_" $"($stashdir)/home-manager"

let workdir = "/var/lib/github-actions-runners/raisin-default/work/nixcfg/"
sudo rm -rf $"($workdir)/nixpkgs"
sudo rm -rf $"($workdir)/home-manager"
