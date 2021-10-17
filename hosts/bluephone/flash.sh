#!/usr/bin/env bash
set -x
set -ueo pipefail

result="$(nix eval --raw "../..#images.bluephone")"
fastboot reboot bootloader
fastboot set_active b
fastboot reboot recovery
fastboot set_active a
fastboot flash userdata "${result}/rootfs.img"
fastboot flash boot "${result}/boot.img"
fastboot set_active b # we should have the same bootloader probably... but just in case
fastboot reboot bootloader
fastboot set_active a
# reset boot counter here maybe?
fastboot reboot
