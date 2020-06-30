#!/usr/bin/env bash
set -euo pipefail
set -x

## NIXPKGS
cd ~/code/nixpkgs/master
git remote update
git reset --hard nixpkgs/master
git push origin HEAD -f

cd ~/code/nixpkgs/pulls
for f in *; do
  (
    cd $f
    git rebase nixpkgs/master
    git push origin HEAD -f
  )
done

## HOME_MANAGER
cd ~/code/home-manager/master
git remote update
git reset --hard rycee/master
git push origin HEAD -f

cd ~/code/home-manager/pulls
for f in *; do
  (
    cd $f
    git rebase rycee/master
    git push origin HEAD -f
  )
done