#!/usr/bin/env bash

set -x
set -euo pipefail

git fetch --all
git switch main-next-wip
git reset --hard origin/main

nix flake update --commit-lock-file

if git diff --exit-code HEAD origin/main-next-wip; then
  echo "no material flake.lock diff"
  echo "abandoning"
  exit 0
fi

git push --force-with-lease origin main-next-wip
