#!/usr/bin/env bash
set -euo pipefail
set -x

function nix() {
  ../../nixup _nix "${@}"
}

SDCARD_ID="/dev/disk/by-id/usb-Mass_Storage_Device_121220160204-0:0"
SDCARD_ROOT="/dev/disk/by-id/usb-Mass_Storage_Device_121220160204-0:0-part2"

rm -f /tmp/rpizero2
nix build --out-link /tmp/rpizero2 "../..#images.rpizero2"
zstdcat /tmp/rpizero2/sd-image/nixos-sd-image-*.img.zst \
  | sudo dd if=/dev/stdin of="${SDCARD_ID}" bs=4M;

sudo udevadm settle

# add our tailscale key

mkdir -p /tmp/root
trap 'sudo umount /tmp/root' EXIT
sudo mount "${SDCARD_ROOT}" /tmp/root

set +x
TSKEY="$(cat /run/secrets/tailscale-join-authkey)"
echo -n "${TSKEY}" | sudo tee /tmp/root/tailscale-key.txt >/dev/null
set -x

sudo sync
