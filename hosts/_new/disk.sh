#!/usr/bin/env bash
set -x
set -euo pipefail

POOL="tank2"
LUKSLABEL="newluks"
NIXOSLABEL="newnixos"
BOOTLABEL="newboot"
DISK="/dev/disk/by-id/nvme-KXG50ZNV1T02_NVMe_TOSHIBA_1024GB_Y77S101VTYAT"

function disk() {
  sudo cryptsetup luksClose "${NIXOSLABEL}" || true

  sudo zpool destroy -f "${POOL}" || true
  sudo umount "/mnt/boot" || true
  sudo umount "/mnt" || true
  sudo zpool destroy -f "${POOL}" || true

  sudo wipefs -a "${DISK}"
  sudo dd if=/dev/zero of="${DISK}" bs=512 count=10

  sudo parted --script "${DISK}" \
    mklabel gpt \
    mkpart primary 1MiB 512MiB \
    mkpart primary 512MiB 100% \
    set 1 boot on \
    name 1 "${BOOTLABEL}" \
    name 2 "${LUKSLABEL}"

  sudo udevadm settle

  # LUKS
  sudo cryptsetup luksFormat "/dev/disk/by-partlabel/${LUKSLABEL}"
  sudo cryptsetup luksOpen   "/dev/disk/by-partlabel/${LUKSLABEL}" "${NIXOSLABEL}"

  # ROOT / zfs
  sudo mkdir -p "/mnt"
  sudo zpool create -O mountpoint=none -R "/mnt" "${POOL}" "/dev/mapper/${NIXOSLABEL}"
  sudo zfs create -o mountpoint=legacy -o compression=lz4 -o xattr=sa -o acltype=posixacl -o atime=off "${POOL}/nix"
  sudo zfs create -o mountpoint=legacy -o compression=lz4 -o xattr=sa -o acltype=posixacl "${POOL}/root"
  sudo zfs create -o mountpoint=legacy -o compression=lz4 -o xattr=sa -o acltype=posixacl "${POOL}/home"
  sudo zpool set autotrim=on "${POOL}" # enable autotrim
}

function install() {

  # reset mounts
  #sudo umount /mnt/{nix,persist,semivolatile} || true
  #sudo umount /mnt/boot || true
  #sudo umount /mnt || true
  #sudo zpool destroy tank2
  #sudo cryptsetup luksClose "${NIXOSLABEL}" || true

  # start
  #sudo cryptsetup luksOpen "/dev/disk/by-partlabel/${LUKSLABEL}" "${NIXOSLABEL}"
  sudo cryptsetup luksOpen   "/dev/disk/by-partlabel/${LUKSLABEL}" "${NIXOSLABEL}"
  
  sudo zpool import "${POOL}" || true
  sudo mkdir -p /mnt
  sudo mount -t zfs "${POOL}/root" /mnt
  sudo mkdir -p /mnt/{nix,persist,semivolatile}
  sudo mount -t zfs "${POOL}/nix" /mnt/nix
  sudo mount -t zfs "${POOL}/persist" /mnt/persist
  sudo mount -t zfs "${POOL}/semivolatile" /mnt/semivolatile

  # BOOT
  sudo mkdir -p /mnt/boot
  sudo mkfs.vfat -n ${BOOTLABEL} /dev/disk/by-partlabel/${BOOTLABEL}
  sudo mount "/dev/disk/by-partlabel/${BOOTLABEL}" /mnt/boot

  echo "*******************************"
  echo "install now:"
  echo sudo nixos-install --root /mnt --system "/nix/store/p5f8nvknhnjclsh9y7mx68x335jl3zqg-nixos-system-slynux-20.09.20200815.5c463eb"

}

cmd="${1}"; shift

"${cmd}" "${@}";
