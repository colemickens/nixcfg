#!/usr/bin/env bash

git switch -C main-next-wip
git reset --hard origin/main
git push origin HEAD -f

nix flake update --commit-lock-file

# TODO(colemickens): confirm this puts nix flake inputs into cache?
nix flake archive

git push --set-upstream origin main-next-wip
