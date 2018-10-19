#!/usr/bin/env bash
set -x
set -euo pipefail

# clone nixpkgs
if [[ ! -d /etc/nixpkgs-raw ]]; then
  sudo mkdir -p /etc/nixpkgs-raw
  sudo git clone --bare https://github.com/colemickens/nixpkgs /etc/nixpkgs-raw
fi

pushd /etc/nixpkgs-raw
sudo git config --local --add remote.origin.fetch "+refs/heads/*:refs/remotes/origin/*"
popd

# other nixpkgs branches we use
pushd /etc/nixpkgs-raw
for b in $(sudo git ls-remote --heads origin  | sed 's?.*refs/heads/??') ; do
  if [[ ! -d "/etc/nixpkgs-${b}" ]]; then
    sudo git worktree add "/etc/nixpkgs-${b}" "${b}"
  fi
done
popd

# make my normal user the owner
sudo chown -R 1000:1000 /etc/nixpkgs*

