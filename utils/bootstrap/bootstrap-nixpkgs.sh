#!/usr/bin/env bash
set -x
set -euo pipefail

# clone nixpkgs
if [[ ! -d /etc/nixpkgs-raw ]]; then
  sudo git clone --bare https://github.com/colemickens/nixpkgs /etc/nixpkgs-raw
fi

# other nixpkgs branches we use
cd /etc/nixpkgs-raw
for b in $(sudo git ls-remote --heads origin  | sed 's?.*refs/heads/??') ; do
  if [[ ! -d "/etc/nixpkgs-${b}" ]]; then
    sudo git worktree add "/etc/nixpkgs-${b}" "${b}"
  fi
done

# make my normal user the owner
sudo chown -R 1000:1000 /etc/nixpkgs*

