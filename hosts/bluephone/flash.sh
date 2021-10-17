#!/usr/bin/env bash
set -x
set -ueo pipefail

result="$(nix eval --raw "../..#images.bluephone")"

mkdir -p /tmp/bluephone/{boot,system}
unar -o /tmp/bluephone/boot "${result}/flashable-google-blueline-boot.zip"
unar -o /tmp/bluephone/system "${result}/flashable-google-blueline-system.zip"

exit 0

# get into whatever bootloader (we think both bootloaders are likely just bl-0.4 (aka android-12))
fastboot reboot bootloader

# get into known good android12 fastbootd
fastboot set_active b
fastboot reboot fastboot

# in good fastbootd, switch to slot_a and flash mobile-nixos system->userdata
fastboot set_active a
fastboot flash userdata "${result}/rootfs.img"
# switch back to known good, reboot to bootloader
fastboot set_active b
fastboot reboot bootloader

# switch slot back to mobile-nixos
fastboot set_active a
fastboot flash boot "${result}/boot.img"
# reset boot counter here maybe?

fastboot reboot
