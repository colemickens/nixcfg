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

# TODO: check that all partitions exist already
# or else warn the user to go make parts first at least

# TODO: re-add option for detached luks header
# TODO: turn all of this into a "script" output by a nixos module (thus web ui support, etc)

action="${1}"
hn="${2}"
system="${3}"

installmnt="/mnt-install"

POOL="${hn}pool"
LDM="${hn}-luks"
LUKSPART="/dev/disk/by-partlabel/${LDM}"
LUKSMNT="/dev/mapper/${LDM}"
BOOT="/dev/disk/by-partlabel/${hn}-boot"
SWAP="/dev/disk/by-partlabel/${hn}-swap"

TMPLUKSKEY="/tmp/lukspw-${hn}"

###############################################################################
# TEARDOWN
function teardown() {
  sudo sync; sudo sync
  
  sudo umount ${installmnt}/boot || true
  sudo umount ${installmnt}/nix || true
  sudo umount ${installmnt}/home || true
  sudo umount ${installmnt}/backup || true
  sudo umount ${installmnt}/persist || true
  sudo umount ${installmnt}/ || true

  sudo zpool export "${POOL}" || true

  sudo cryptsetup luksClose "${LDM}" || true
}

###############################################################################
# DISKINIT
function diskinit() {
  # --header "${DETACHED_LUKS_HEADER}" \
  luksopts=(
    --type luks2
    --cipher xchacha12,aes-adiantum-plain64
    --hash sha512
    --iter-time 5000
    --use-urandom
    --key-size 256
    --sector-size 4096
  )
  luksopts=(
    --type luks2
  )
  sudo cryptsetup -v \
    "${luksopts[@]}" \
    --batch-mode luksFormat \
    "${LUKSPART}" \
    "${TMPLUKSKEY}"
  
  sudo cryptsetup luksAddKey \
    "${LUKSPART}" \
    --key-file "${TMPLUKSKEY}"

  # # --header "${DETACHED_LUKS_HEADER}" \
  sudo cryptsetup luksOpen \
    --key-file "${TMPLUKSKEY}" \
    "${LUKSPART}" \
    "${LDM}"

  # ROOT / zfs
  sudo mkdir -p "${installmnt}"
  sudo zpool create -f -O mountpoint=none -R "${installmnt}" "${POOL}" "${LUKSMNT}"
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
  
  sudo mount -t zfs "${POOL}/root" "${installmnt}"
  sudo mkdir "${installmnt}/boot"
  # TODO: WARNING THIS BLOWS OUT THE WINDOWS BOOTLOADER!!!
  # sudo mkfs.vfat -F32 "/dev/disk/by-partlabel/${hn}-boot"
  sudo mount "/dev/disk/by-partlabel/${hn}-boot" "${installmnt}/boot"
  
  # TODO: do something here to indicate that diskinit was completed
  # so that we can skip it on future runs?
}

function mounts() {
  mkdir -p "${installmnt}"
  cryptsetup luksOpen --key-file "${TMPLUKSKEY}" "${LUKSPART}" "${LDM}"

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

  # if zfs list "${hn}pool/backup"; then
  #   mkdir -p "${installmnt}/backup"
  #   mount -t zfs ${hn}pool/backup "${installmnt}/backup"
  # fi
  if zfs list "${hn}pool/persist"; then
    mkdir -p "${installmnt}/persist"
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
  
  # TODO: don't always do this, it's a bit destructive
  # rm -rf "${installmnt}/nix/var/nix/profiles/system"*
  
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
if [[ "${action}" = "diskinit" ]]; then
  diskinit
elif [[ "${action}" == "install" ]]; then
  mounts
  install
fi
teardown

