#!/usr/bin/env bash
set -euo pipefail
set -x

if [[ "${TF_NIXOS_LUSTRATE:-""}" == "true" ]]; then
  sudo /home/cole/.nix-profile/bin/nix build --no-link --profile /nix/var/nix/profiles/system \
    "github:colemickens/nixcfg#toplevels.oracular"
  sudo umount /dev/disk/by-label/UEFI
  sudo find /boot -depth ! -path /boot -exec sudo rm -rf {} +
  sudo mount /dev/disk/by-label/UEFI /boot
  sudo find /boot -depth ! -path /boot -exec sudo rm -rf {} +
  sudo touch /etc/NIXOS
  echo "" | sudo tee -a /etc/NIXOS_LUSTRATE
  sudo env NIXOS_INSTALL_BOOTLOADER=1 /nix/var/nix/profiles/system/bin/switch-to-configuration boot
  true
fi

echo "nixos-takeover: all done!"
