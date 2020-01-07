#!/usr/bin/env bash
set -euo pipefail
set -x

cd ~/code/nixpkgs
git remote update
git rebase nixpkgs/nixos-unstable
sudo bash -c "ulimit -s 100000; nixos-rebuild switch"

exit 0

desktop="${1:-"sway"}"
target="${1:-"$(hostname)-${desktop}"}"
toplevel=$(./nixbuild.sh default.nix -A "${target}")

sudo nix-env --set \
  --profile "/nix/var/nix/profiles/system" \
  "${toplevel}"

sudo "${toplevel}/bin/switch-to-configuration" switch

