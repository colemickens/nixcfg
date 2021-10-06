#!/usr/bin/env bash
set -x

mkdir ../nixpkgs
mkdir ../home-manager
git clone git@github.com:colemickens/nixpkgs ../home-manager/cmhm
git clone git@github.com:colemickens/nixpkgs ../nixpkgs/cmpkgs

pushd ../nixpkgs/cmpkgs;
git reset --hard origin/cmpkgs;
git checkout -b next
git worktree add ../crosspkgs
cd ../crosspkgs
git checkout -b next
popd

# TODO: investigate a long-running service that does this and can be aware of git remotes/etc to manage them
# rebase both ontop of their bases branches 'nixos-unstable'

# try to rebuild "bundles" and then "crossBundles"
pushd ../nixpkgs/cmpkgs
git rebase nixos/nixos-unstable
popd

pushd ../home-manager/cmhm
git rebase nix-community/master
popd

git checkout -b auto-advance

overrides=(
  --override-input nixpkgs ../nixpkgs/cmpkgs \
  --override-input crosspkgs ../nixpkgs/crosspkgs \
  --override-input home-manager ../home-manager/cmhm
)
./nixup _nb ".#bundle.aarch64-linux" \
  --eval-store auto --store "ssh-ng://cole@$(tailscale ip --6 oracular)" \
  "${overrides[@]}"

./nixup _nb ".#bundle.x86_64-linux" "${overrides[@]}"
