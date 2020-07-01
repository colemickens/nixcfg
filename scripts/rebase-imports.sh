#!/usr/bin/env bash
set -euo pipefail
set -x

# TODO: tool to help do this?

##### NIXPKGS
# master
cd ~/code/nixpkgs/master
git remote update
git reset --hard nixpkgs/master
git push origin HEAD -f

# cmpkgs
cd ~/code/nixpkgs/cmpkgs;
(git rebase nixpkgs/nixos-unstable-small && git push origin HEAD -f) || true

# pipkgs
cd ~/code/nixpkgs/pipkgs;
(git rebase nixpkgs/nixos-unstable && git push origin HEAD -f) || true

##### HOME_MANAGER
# master
cd ~/code/home-manager/master
git remote update
git reset --hard rycee/master
git push origin HEAD -f

# # bqv-flakes (rycee/bqv-flakes)
# (cd ~/code/home-manager/bqv-flakes;
# git remote update;
# git rebase rycee/bqv-flakes || git rebase --abort)

# # CMHM-flakes (bqv-flakes)
# (cd ~/code/home-manager/cmhm-flakes;
# git reset
# git rebase bqv-flakes || git rebase --abort)

# # CMHM (rycee/master)
# (cd ~/code/home-manager/cmhm;
# git remote update;
# git rebase rycee/bqv-flakes || git rebase --abort)

# WAYLAND (CI driven, make sure we aren't accidentally holding ourselves back)
cd ~/code/overlays/nixpkgs-wayland
git remote update
git reset --hard origin/master
