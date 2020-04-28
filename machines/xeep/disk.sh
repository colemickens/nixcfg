#!/usr/bin/env bash
set -x
set -euo pipefail

# rpool2/
# rpool2/enc
# rpool2/nixos/enc/var-lib
# rpool2/nixos/enc/


sudo modprobe zfs

sudo zpool create \
  -O atime=off \
  -O compression=lz4 \
  -O normalization=formD \
  -O xattr=sa \
  -O acltype=posixacl \
  -o ashift=12 \
  -O mountpoint=none \
  -R /mnt \
  rpool2 /dev/nvme0n1p2

sudo zfs create \
  -o acltype=posixacl \
  -o xattr=sa \
  -o encryption=aes-256-gcm \
  -o keyformat=passphrase \
  -o keylocation=prompt \
  -o mountpoint=legacy \
  rpool2/nixos

sudo zfs create \
  -o acltype=posixacl \
  -o xattr=sa \
  -o encryption=aes-256-gcm \
  -o keyformat=passphrase \
  -o keylocation=prompt \
  -o mountpoint=legacy \
  rpool2/home

sudo mkdir -p /mnt
sudo mount -t zfs -l rpool2/nixos /mnt
sudo mkdir /mnt/{boot,home}
sudo mount /dev/nvme0n1p1 /mnt/boot
sudo mount -t zfs -l rpool2/home /mnt/home

# then, mount
# then, copy/symlink in config
# then, nixos-install
# then reboot & sync data
# then delete old partition, expand p2

