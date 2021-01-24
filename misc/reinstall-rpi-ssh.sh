#!/usr/bin/env bash
set -euo pipefail
set -x

p=$1
#POOL="tank"
POOL="rpool"

HOST=nixos@localhost
PORT=22022

BOOTLABEL="rpi2-boot"

ssh -q ${HOST} -p${PORT} <<SSHSSH
  set -x
  set -e

  sudo umount /mnt/nix || true
  sudo umount /mnt/boot || true
  sudo umount /mnt || true
  sudo zpool export "${POOL}" || true; sleep 1
  sudo zpool import -f "${POOL}"
  sudo mount -t zfs ${POOL}/root /mnt

  sudo rm -rf /mnt/boot /mnt/nix

  sudo mkdir -p /mnt/boot
  sudo mount /dev/disk/by-partlabel/${BOOTLABEL} /mnt/boot

  sudo mkdir -p /mnt/nix
  sudo mount -t zfs ${POOL}/nix /mnt/nix

  sudo rm -rf /mnt/boot/*

  if ! sudo nixos-enter --root /mnt --command "echo 'nameserver 192.168.1.1' | sudo tee /etc/resolv.conf; \
    rm -rf /root/.cache
    nix-store \
      --option 'extra-binary-caches' 'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org' \
      --option 'trusted-public-keys' 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=' \
      --option 'build-cores' '0' \
      --option 'narinfo-cache-negative-ttl' '0' \
      -r $p"; then
    sudo nix-store -r $p  --option 'extra-binary-caches' 'https://cache.nixos.org https://colemickens.cachix.org https://nixpkgs-wayland.cachix.org' --option 'trusted-public-keys' 'cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA='
  fi
  sudo nixos-install --root /mnt --system $p
  sudo sync; sudo sync
  sudo umount /mnt/boot
  sudo umount /mnt/nix
  sudo umount /mnt
  sudo zpool export ${POOL}
SSHSSH
