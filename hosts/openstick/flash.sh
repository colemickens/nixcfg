#!/usr/bin/env bash

set -x

# NOTE: must flash openstick build first:
# https://archive.org/details/uf-896-v-1.1-dumps-20240107-t-053928-z-001

# download, unzip, fixup ./flash.sh scripts
# don't forget to flash our aboot for the button fix!
# (not that we did for openstick2 and are too lazy to fix since we did flash boot)

# TODO: ideally, we don't really use any of this
# but it does "fix" the partition table in a way we need.
# it would be better to see if there's a way to do this...? with fastboot?

p="/tmp/openstick"

[[ -e $p-aboot ]] || nix build --out-link $p-aboot .#extra.x86_64-linux.openstick-abootimg
[[ -e $p-boot ]] || nix build --out-link $p-boot .#extra.x86_64-linux.openstick-bootimg
[[ -e $p-rootfs ]] || nix build --out-link $p-rootfs .#extra.x86_64-linux.openstick-rootfs

adb reboot bootloader || true

fastboot flash aboot $p-aboot

fastboot erase boot
fastboot flash boot $p-boot

fastboot erase rootfs
fastboot flash rootfs $p-rootfs/rootfs.img
