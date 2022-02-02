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

# BUILD TOW-BOOT GENERIC RPI IMAGE
# TODO: check and sure overrides compose
TBATTR="towboot_rpi_combined"
./nixup "${TBATTR}" \
  --override-input 'towboot' "${TOWBOOT}" \
  --override-input 'nixpkgs' "${NIXPKGS_WORKTREE}"
TOWBOOT_OUT="$(nix eval --raw "..#${TBATTR}")"

#
# DEPLOY+ACTIVATE RPIFOUR1 TOPLEVEL
./nixup rpifour \
  --override-input 'towboot' "${TOWBOOT}" \
  --override-input 'nixpkgs' "${NIXPKGS_WORKTREE}"

#
# REMOUNT FIRMWARE
ssh cole@"$(tailscale ip --6 rpifour1)" "sudo mount -oremount,rw /boot/firmware"

#
# EEPROM
# we have already activated top-level which pulls in tow-boots rpi tools:
ssh cole@"$(tailscale ip --6 rpifour1)" "sudo tb-rpi-update-eeprom"

#
# FIRMWARE

# TODO::::::
rsync "${TOWBOOT_OUT}/firmware" "cole@$(tailscale ip --6 rpifour1):/home/cole/rpifirmware"
# do a slightly weird swap so that we keep "old" on the firmware part
ssh cole@"$(tailscale ip --6 rpifour1)" "sudo mv /home/cole/rpifirwmare /boot/firmware/new"
ssh cole@"$(tailscale ip --6 rpifour1)" "sudo mkdir -p /boot/firmware/old"
ssh cole@"$(tailscale ip --6 rpifour1)" "sudo mv /boot/firmware/!(new|old) /boot/firmware/old/"
ssh cole@"$(tailscale ip --6 rpifour1)" "sudo mv /boot/firmware/new/* /boot/firmware/"
ssh cole@"$(tailscale ip --6 rpifour1)" "sudo rmdir /boot/firmware/new"

sleep 100000

#
# REBOOT (and remount firmware ro)
ssh cole@"$(tailscale ip --6 rpifour1)" "sudo reboot"
sleep 60

#
# CLEANUP
ssh cole@"$(tailscale ip --6 rpifour1)" "sudo rm -rf /boot/firmware/old"
