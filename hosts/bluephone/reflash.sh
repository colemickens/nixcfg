#!/usr/bin/env bash
set -x
set -ueo pipefail

fastboot reboot recovery
# normalize radio/bootloader/boot to start with, duplicate slot b steps in a to start from scratch
fastboot set_active a
d="${HOME}/downloads/blueline-spb5.210812.002-factory-6390aefc/blueline-spb5.210812.002"
fastboot flash radio "${d}/radio-blueline-g845-00194-210812-b-7635520.img"
fastboot flash bootloader "${d}/bootloader-blueline-b1c1-0.4-7617406.img"
fastboot flash boot "${d}/boot.img"
fastboot reboot fastboot
# now start over but mainly get the "known good" on slot b
fastboot set_active b
d="${HOME}/downloads/blueline-spb5.210812.002-factory-6390aefc/blueline-spb5.210812.002"
fastboot flash radio "${d}/radio-blueline-g845-00194-210812-b-7635520.img"
fastboot flash bootloader "${d}/bootloader-blueline-b1c1-0.4-7617406.img"
fastboot flash boot "${d}/boot.img"
fastboot reboot fastboot
fastboot flash boot "${d}/boot.img"
fastboot flash dtbo "${d}/dtbo.img"
fastboot flash vendor "${d}/vendor.img"
fastboot flash vbmeta "${d}/vbmeta.img"
