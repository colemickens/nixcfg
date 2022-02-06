#!/bin/sh
set -euo pipefail
set -x

# export UPSTREAM="cmpkgs" # TODO: replace
# #export UPSTREAM="nixos/nixos-unstable" # TODO replace

# export NIXPKGS="/home/cole/code/nixpkgs/cmpkgs"
# export NIX_PATH="nixpkgs=/home/cole/code/nixpkgs/cmpkgs"
export NIXPKGS_WORKTREE="/home/cole/code/nixpkgs/rpi-updates-auto"
# export WORKTREE="rpi-updates-auto"
export TOWBOOT="/home/cole/code/tow-boot"

export ARCH="x86_64-linux" # what system you're doing the update from

cd ~/code/nixcfg

#
# DEPLOY+ACTIVATE RPIFOUR1 TOPLEVEL
./nixup rpifour1 \
  --override-input 'tow-boot' "${TOWBOOT}" \
  --override-input 'nixpkgs' "${NIXPKGS_WORKTREE}"

#
# DEPLOY+ACTIVATE RPIZEROTWO1 TOPLEVEL
./nixup rpizerotwo1 \
  --override-input 'tow-boot' "${TOWBOOT}" \
  --override-input 'nixpkgs' "${NIXPKGS_WORKTREE}"

ssh cole@"$(tailscale ip --6 rpifour1)" "sudo tow-boot-rpi-update"
ssh cole@"$(tailscale ip --6 rpizerotwo1)" "sudo tow-boot-rpi-update"
