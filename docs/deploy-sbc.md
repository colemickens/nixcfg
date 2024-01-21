# deployment

deployment notes for needy systems, so far, sbcs:

## openstick
- use adb to reboot to fastboot
- install stuff from the openstick release that fixes gpt at least
- flash updated aboot *first*
- flash boot
- flash system
- should be notes in it

# rock5b
- flash uefi for rock5b release
- install with our normal nixos installer-standard-aarch64 iso

# radxazero1
- ?

# h96maxv58
- install ubuntu img? lul?
```
sudo rkdeveloptool wl 0x40 ~/code/nixcfg/result/binaries/Tow-Boot.noenv.bin
```