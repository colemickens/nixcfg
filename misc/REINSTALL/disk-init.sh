#!/usr/bin/env bash
set -x
set -euo pipefail
DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
if [ "$EUID" -ne 0 ]; then echo "Please run as root"; exit; fi

####
## This is meant to be used over 'ssh' to a nixos install media.
## It's primarily setup to be able to quickly remount everything.
##
## written to run from slywin to fix slynux(${hn})
##
####

hn="${1}"
installmnt="/mnt-install"

POOL="${hn}pool"
LDM="${hn}-luks"
LUKSPART="/dev/disk/by-partlabel/${LDM}"
LUKSMNT="/dev/mapper/${LDM}"
BOOT="/dev/disk/by-partlabel/${hn}-boot"
SWAP="/dev/disk/by-partlabel/${hn}-swap"

TMPLUKSKEY="/tmp/luks-${hn}"

# TODO: check that all partitions exist already
# or else warn the user to go make parts first at least

# TODO: re-add option for detached luks header
# TODO: turn all of this into a "script" output by a nixos module (thus web ui support, etc)

  # --header "${DETACHED_LUKS_HEADER}" \
function diskinit() {
  sudo cryptsetup -v \
    --type luks2 \
    --cipher xchacha12,aes-adiantum-plain64 \
    --hash sha512 \
    --iter-time 5000 \
    --use-urandom \
    --batch-mode luksFormat \
    --key-size 256 \
    --sector-size 4096 \
    "${LUKSPART}" \
    "${TMPLUKSKEY}"

  # --header "${DETACHED_LUKS_HEADER}" \
  sudo cryptsetup luksOpen \
    --key-file "${TMPLUKSKEYFILE}" \
    "${LUKSPART}" \
    "${LDM}"

  # ROOT / zfs
  sudo mkdir -p "${installmnt}"
  sudo zpool create -O mountpoint=none -R "${installmnt}" "${POOL}" "${LUKSMNT}"
  sudo zfs create -o mountpoint=legacy -o compression=zstd -o xattr=sa -o acltype=posixacl -o atime=off "${POOL}/nix"
  sudo zfs create -o mountpoint=legacy -o compression=zstd -o xattr=sa -o acltype=posixacl -o relatime=on "${POOL}/root"
  sudo zfs create -o mountpoint=legacy -o compression=zstd -o relatime=on "${POOL}/home"
  sudo zfs create -o mountpoint=legacy -o compression=zstd -o relatime=on "${POOL}/persist"
  sudo zpool set autotrim=on "${POOL}" # enable autotrim
  
  # auto-snapshot our important dataz
  sudo zfs set com.sun:auto-snapshot=true "${hn}pool/home"
  sudo zfs set com.sun:auto-snapshot=true "${hn}pool/persist"
  
  # snapshot root at blank for "erase your darlings"
  sudo zfs snapshot "${POOL}/root@blank"
}

###############################################################################
# PREP
function teardown() {
  sudo sync; sudo sync
  
  sudo umount ${installmnt}/boot
  sudo umount ${installmnt}/nix
  sudo umount ${installmnt}/home
  sudo umount ${installmnt}/persist || true
  sudo umount ${installmnt}/

  sudo zpool export "${hn}pool"

  sudo cryptsetup luksClose "${LDM}"
}

set +e; teardown; set -e
mounts
install
#teardown
