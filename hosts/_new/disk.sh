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

TMPLUKSKEYFILE="/tmp/lukspw"; echo -e "password" > "${TMPLUKSKEYFILE}"

buildargs=(
  --option 'extra-binary-caches' 'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org https://arm.cachix.org https://thefloweringash-armv7.cachix.org'
  --option 'trusted-public-keys' 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA= arm.cachix.org-1:5BZ2kjoL1q6nWhlnrbAl+G7ThY7+HaBRD9PZzqZkbnM= thefloweringash-armv7.cachix.org-1:v+5yzBD2odFKeXbmC+OPWVqx4WVoIVO6UXgnSAWFtso='
  --option 'build-cores' '0'
  --option 'narinfo-cache-negative-ttl' '0'
)

function disk() {
  sudo umount "/mnt/boot" || true
  sudo umount "/mnt/home" || true
  sudo umount "/mnt/nix" || true
  sudo umount "/mnt" || true
  sudo zpool destroy -f "${POOL}" || true
  sudo cryptsetup luksClose "${DEVMAPPER_NAME}" || true

  sudo wipefs -a "${DISK}"
  sudo dd if=/dev/zero of="${DISK}" bs=512 count=10

  sudo parted --script "${DISK}" \
    mklabel gpt \
    mkpart "${BOOTLABEL}" fat32      1MiB      1GiB \
    set 1 esp on \
    mkpart "${LUKSLABEL}" ext4       1GiB    1025GiB \
    mkpart "${SWAPLABEL}" linux-swap 1025GiB 1041GiB \
    mkpart "${WINLABEL}"             1041GiB   100%

  sudo udevadm settle

  # LUKS
  sudo cryptsetup luksFormat --batch-mode "/dev/disk/by-partlabel/${LUKSLABEL}" "${TMPLUKSKEYFILE}"
  sudo cryptsetup luksOpen   --key-file "${TMPLUKSKEYFILE}" "/dev/disk/by-partlabel/${LUKSLABEL}" "${DEVMAPPER_NAME}"

  # ROOT / zfs
  sudo mkdir -p "/mnt"
  sudo zpool create -O mountpoint=none -R "/mnt" "${POOL}" "/dev/mapper/${DEVMAPPER_NAME}"
  sudo zfs create -o mountpoint=legacy -o compression=zstd -o xattr=sa -o acltype=posixacl -o atime=off "${POOL}/nix"
  sudo zfs create -o mountpoint=legacy -o compression=zstd -o xattr=sa -o acltype=posixacl "${POOL}/root"
  sudo zfs create -o mountpoint=legacy -o compression=zstd -o xattr=sa -o acltype=posixacl "${POOL}/persist"
  sudo zpool set autotrim=on "${POOL}" # enable autotrim

  # snapshot root at blank for "erase your darlings"
  sudo zfs snapshot "${POOL}/root@blank"
}

function install() {
  rev="${1}"

  # reset mounts
  sudo umount /mnt/home || true
  sudo umount /mnt/nix || true
  sudo umount /mnt/boot || true
  sudo umount /mnt || true
  sudo zpool export "${POOL}" || true
  sudo cryptsetup luksClose "${DEVMAPPER_NAME}" || true

  # start
  sudo cryptsetup luksOpen   --key-file "${TMPLUKSKEYFILE}" "/dev/disk/by-partlabel/${LUKSLABEL}" "${DEVMAPPER_NAME}"
  
  sudo zpool import "${POOL}"
  
  sudo mkdir -p /mnt
  sudo mount -t zfs "${POOL}/root" /mnt
  
  sudo mkdir -p /mnt/nix
  sudo mount -t zfs "${POOL}/nix" /mnt/nix
  
  sudo mkdir -p /mnt/home
  sudo mount -t zfs "${POOL}/home" /mnt/home

  # BOOT
  sudo mkdir -p /mnt/boot
  sudo mkfs.vfat -n ${BOOTLABEL} /dev/disk/by-partlabel/${BOOTLABEL}
  sudo mount "/dev/disk/by-partlabel/${BOOTLABEL}" /mnt/boot

  echo "*******************************"
  echo "install now:"
  sleep 3
  sudo nix-store -r --store /mnt "${buildargs[@]}" "${1}"
  sudo nixos-install --root /mnt --system "${1}" "${buildargs[@]}"

  echo "*******************************"
  echo "fix up luks:"
  sleep 3
  sudo cryptsetup luksAddKey --key-file "${TMPLUKSKEYFILE}" "/dev/disk/by-partlabel/${LUKSLABEL}"
  sudo cryptsetup luksRemoveKey "/dev/disk/by-partlabel/${LUKSLABEL}" "${TMPLUKSKEYFILE}"
}

cmd="${1}"; shift

"${cmd}" "${@}";
