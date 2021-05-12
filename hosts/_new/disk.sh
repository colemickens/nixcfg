#!/usr/bin/env bash
set -x
set -euo pipefail
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"

POOL="raisintank"
LUKSLABEL="luksroot"
NIXOSLABEL="nixosroot"
DEVMAPPER_NAME="${NIXOSLABEL}"
BOOTLABEL="boot"
SWAPLABEL="swap"
WINLABEL="windows"
DISK="/dev/disk/by-id/nvme-Samsung_SSD_970_EVO_Plus_2TB_S4J4NG0M603073J"

function disk() {
  sudo cryptsetup luksClose "${DEVMAPPER_NAME}" || true

  sudo zpool destroy -f "${POOL}" || true
  sudo umount "/mnt/boot" || true
  sudo umount "/mnt" || true
  sudo zpool destroy -f "${POOL}" || true

  sudo wipefs -a "${DISK}"
  sudo dd if=/dev/zero of="${DISK}" bs=512 count=10

  sudo parted --script "${DISK}" \
    mklabel gpt \
    mkpart "${BOOTLABEL}" fat32      1MiB    512MiB \
    set 1 esp on \
    mkpart "${LUKSLABEL}" ext4       512MiB  1024GiB \
    mkpart "${SWAPLABEL}" linux-swap 1024GiB 1040GiB \
    mkpart "${WINLABEL}"             1040GiB 100%

  sudo udevadm settle

  # LUKS
  sudo cryptsetup luksFormat "/dev/disk/by-partlabel/${LUKSLABEL}"
  sudo cryptsetup luksOpen   "/dev/disk/by-partlabel/${LUKSLABEL}" "${DEVMAPPER_NAME}"

  # ROOT / zfs
  sudo mkdir -p "/mnt"
  sudo zpool create -O mountpoint=none -R "/mnt" "${POOL}" "/dev/mapper/${DEVMAPPER_NAME}"
  sudo zfs create -o mountpoint=legacy -o compression=zstd -o xattr=sa -o acltype=posixacl -o atime=off "${POOL}/nix"
  sudo zfs create -o mountpoint=legacy -o compression=zstd -o xattr=sa -o acltype=posixacl "${POOL}/root"
  sudo zfs create -o mountpoint=legacy -o compression=zstd -o xattr=sa -o acltype=posixacl "${POOL}/home"
  sudo zpool set autotrim=on "${POOL}" # enable autotrim
}

function install() {
  rev="${1}"

  if [[ "$(hostname)" == "nixos" ]]; then
    echo "set hostname"
    exit -1
  fi

  # reset mounts
  sudo umount /mnt/nix || true
  sudo umount /mnt/boot || true
  sudo umount /mnt || true
  sudo zpool destroy tank2
  sudo cryptsetup luksClose "${DEVMAPPER_NAME}" || true

  # start
  sudo cryptsetup luksOpen   "/dev/disk/by-partlabel/${LUKSLABEL}" "${DEVMAPPER_NAME}"
  
  sudo zpool import "${POOL}" || true
  sudo mkdir -p /mnt
  sudo mount -t zfs "${POOL}/root" /mnt
  sudo mkdir -p /mnt/nix
  sudo mount -t zfs "${POOL}/nix" /mnt/nix

  # BOOT
  sudo mkdir -p /mnt/boot
  sudo mkfs.vfat -n ${BOOTLABEL} /dev/disk/by-partlabel/${BOOTLABEL}
  sudo mount "/dev/disk/by-partlabel/${BOOTLABEL}" /mnt/boot

  echo "*******************************"
  echo "install now:"
  echo sudo nixos-install --root /mnt --system "${1}"
}

cmd="${1}"; shift

"${cmd}" "${@}";
