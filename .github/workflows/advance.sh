#!/usr/bin/env bash
set -x

mkdir ../nixpkgs
mkdir ../home-manager
git clone git@github.com:colemickens/nixpkgs ../home-manager/cmhm
git clone git@github.com:colemickens/nixpkgs ../nixpkgs/cmpkgs

pushd ../nixpkgs/cmpkgs;
git remote add nixos "http://github.com/nixos/nixpkgs"
git remote update

git worktree add ../crosspkgs

git reset --hard origin/cmpkgs;
git checkout -b cmpkgs-next
popd

pushd ../nixpkgs/crosspkgs
git reset --hard origin/crosspkgs;
git checkout -b crosspkgs-next
popd

pushd ../home-manager/cmhm
git reset --hard origin/cmhm
git remote add nix-communtiy "https://github.com/nix-community/home-manager"
git remote update
git rebase -i nix-community/master
git checkout -b cmhm-next
popd


# TODO: investigate a long-running service that does this and can be aware of git remotes/etc to manage them
# rebase both ontop of their bases branches 'nixos-unstable'

# try to rebuild "bundles" and then "crossBundles"

# eval before -> list_1
# eval after -> list_2
# build list_2 -> if okay, then the upgrade was good enough

pushd ../nixpkgs/cmpkgs
git rebase nixos/nixos-unstable
popd

pushd ../nixpkgs/crosspkgs
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

./nixup a64 &
./nixup x64

wait
