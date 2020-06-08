#!/usr/bin/env bash
set -x
set -euo pipefail

# TODO(future): zstd compression (? dear god though, that PR...)
# TODO: ensure we use GCM encryption for speed-up on modern procs?

DISK="${1}"

# wipe as much as possible to make fdisk not prompt about FSes (maybe there's a flag too?)
sudo wipefs -a "${DISK}"
sudo dd if=/dev/zero of="${DISK}" bs=512 count=10

# fdisk script:
# - new GPT
# - new boot partition (1g)
# - new part for zfs (rest)
# - change part types
# - adv menu
# - change labels
# - return to main menu
# - write
echo "g
n


+1G
n



t
1
1
t
2
20
x
n
1
boot
n
2
zfs
r
w
" | sudo fdisk "${DISK}"

# reminder notes on options:
# - none prevents mounting
# - legacy allows mounting with mount/umount tooling (and is needed by nixos)

# TODO: different newer mountpoint type?
# TODO: zstd in future

# services.zfs.autoScrub.enable = true;

# format boot
sudo mkdir -p /mnt/boot
sudo mkfs.vfat -n BOOT /dev/disk/by-partlabel/boot

# format zfs
sudo mkdir -p /mnt
sudo zfs import tank || true
sudo zpool create -O mountpoint=none -R /mnt tank /dev/disk/by-partlabel/zfs
sudo zfs create -o mountpoint=legacy -o compression=lz4 -o xattr=sa -o acltype=posixacl              tank/root
sudo zfs create -o mountpoint=legacy -o compression=lz4 -o xattr=sa -o acltype=posixacl -o atime=off tank/nix
sudo zfs create -o mountpoint=legacy -o compression=lz4 -o xattr=sa -o acltype=posixacl              tank/persist

# if on laptop
# go back and enable encryption option on tank/persist

# mount zfs + boot
sudo zpool import tank || true
sudo mkdir -p /mnt
sudo mount -t zfs tank/root /mnt
sudo mkdir /mnt/{nix,persist}
sudo mount -t zfs tank/nix /mnt/nix
sudo mount -t zfs tank/persist /mnt/persist
sudo mount /dev/disk/by-partlabel/boot /mnt/boot

# copy nixcfg, unlock, whatever AND/OR...
#  do the install if you have an existing $NIXOS_SYSTEM
sudo modprobe zfs

NIXOS_SYSTEM='/nix/store/xbcw9kkdpd7gj83sac03jlxpd39qqlmm-nixos-system-raspberry-20.09pre-git'
sudo nixos-install --root /mnt --system "${NIXOS_SYSTEM}"
