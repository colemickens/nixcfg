#!/usr/bin/env bash
set -x
set -euo pipefail

if [[ ! -d ./fact ]]; then
  echo "you need to download this:"
  echo "https://drive.google.com/file/d/14BqfgThgeAXQCdovgBtF63Nytc29Z5Ne/view?usp=sharing"
  echo "extract it, rename the '2021...' folder as 'fact'."
fi

f="system-squeak-arm64-ab-floss.img"
if [[ ! -f "${f}" ]]; then
  curl -L "https://github.com/phhusson/treble_experimentations/releases/download/v400.c/${f}.xz" \
    | xzcat > "${f}"
fi

f="system-squeak-arm64-ab-vanilla.img"
if [[ ! -f "${f}" ]]; then
  curl -L "https://github.com/phhusson/treble_experimentations/releases/download/v400.c/${f}.xz" \
    | xzcat > "${f}"
fi

f="system-roar-arm64-ab-floss.img"
if [[ ! -f "${f}" ]]; then
  curl -L "https://github.com/phhusson/treble_experimentations/releases/download/v313/${f}.xz" \
    | xzcat > "${f}"
fi

INSTIMG="./system-roar-arm64-ab-floss.img"

fastboot reboot bootloader

#
# DISABLE DM-VERITY
fastboot flash --disable-verity --disable-verification vbmeta "./fact/vbmeta.img"
fastboot flash --disable-verity --disable-verification vbmeta_system "./fact/vbmeta_system.img"
fastboot flash --disable-verity --disable-verification vbmeta_vendor "./fact/vbmeta_vendor.img"

#
# RESET TO FACTORY KNOWN GOOD
# TODO: why is there a recovery.img?
fastboot flash userdata "./fact/userdata.img"
fastboot flash super "./fact/super.img"
fastboot flash boot "./fact/boot.img"
fastboot reboot fastboot

#
# GSI INSTALL
#fastboot delete-logical-partition "product" # make some space (skip now for vanilla, maybe?)
fastboot flash "system" "./${INSTIMG}"
fastboot -w

#
# WOO.... maybe?
fastboot reboot

#
# FAIL
# just shows the "orange" state message, no splash ever appears





#
# NOTES:
# - treble GSI builds:
#   - https://github.com/phhusson/treble_experimentations/releases
# - 
# - recovery steps if we mess up boot:
#   - https://www.reddit.com/r/UnihertzTitan/comments/i33me3/bricked_titan_state_orange_bad_recovery_next_steps/
# 