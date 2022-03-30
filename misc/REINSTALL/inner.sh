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
system="${2}"

installmnt="/mnt-install"

###############################################################################
# PREP
function teardown() {
  sudo sync; sudo sync
  
  sudo umount ${installmnt}/boot
  sudo umount ${installmnt}/nix
  sudo umount ${installmnt}/home
  sudo umount ${installmnt}/backup || true
  sudo umount ${installmnt}/persist || true
  sudo umount ${installmnt}/

  sudo zpool export "${hn}pool"

  sudo cryptsetup luksClose "${hn}-luksroot"
}

function mounts() {
  mkdir -p "${installmnt}"
  cat /tmp/lukspw | cryptsetup luksOpen "/dev/disk/by-partlabel/${hn}-luksroot" "${hn}-luksroot" -

  if ! zpool import -f ${hn}pool; then
    echo "we don't have a pool with the right name, we probably need to"
    echo "do full provisioning, aka partition+format"
   exit -1
  fi

  mount -t zfs ${hn}pool/root "${installmnt}"

  mkdir -p "${installmnt}/nix"
  mount -t zfs ${hn}pool/nix "${installmnt}/nix"

  mkdir -p "${installmnt}/home"
  mount -t zfs ${hn}pool/home "${installmnt}/home"

  if zfs list "${hn}pool/backup"; then
    mkdir -p "${installmnt}/backup"
    mount -t zfs ${hn}pool/backup "${installmnt}/backup"
  fi
  if zfs list "${hn}pool/persist"; then
    mkdir -p "${instalmnt}/persist"
    mount -t zfs ${hn}pool/persist "${installmnt}/persist"
  fi

  mkdir -p "${installmnt}/boot"
  mount /dev/disk/by-partlabel/${hn}-boot "${installmnt}/boot"
}

function install() {
  nixopts=(
    --option substituters 'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org'
    --option trusted-public-keys 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4='
    --option 'build-cores' '0'
    --option 'narinfo-cache-negative-ttl' '0'
  )

  # find "${installmnt}/etc" -mindepth 1 -delete
  rm -rf "${installmnt}/etc/static"
  
  nixos-install \
    --no-channel-copy \
    --root "${installmnt}" \
    --system "${system}" \
    --no-root-password \
    "${nixopts[@]}"
  
  # find "${installmnt}/etc" -mindepth 1 -delete
  rm -rf "${installmnt}/etc/static"
}

set +e; teardown; set -e
mounts
install
#teardown
