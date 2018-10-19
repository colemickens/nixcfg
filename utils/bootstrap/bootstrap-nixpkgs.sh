#!/usr/bin/env bash
set -x
set -euo pipefail

# clone nixpkgs
[[ ! -d /etc/nixpkgs ]] && \
	sudo git clone --bare https://github.com/colemickens/nixpkgs /etc/nixpkgs-raw

# other nixpkgs branches we use
cd /etc/nixpkgs
foreach in list of branches

[[ ! -d /etc/nixpkgs-sway ]] && sudo git worktree add /etc/nixpkgs-sway sway
[[ ! -d /etc/nixpkgs-cmpkgs ]] && sudo git worktree add /etc/nixpkgs-cmpkgs cmpkgs
[[ ! -d /etc/nixpkgs-kata ]] && sudo git worktree add /etc/nixpkgs-kata kata

# make my normal user the owner
sudo chown -R 1000:1000 /etc/nixpkgs*

