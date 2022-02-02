# NixOS on Raspberry Pi 4

0. (TODO: validate) Reconfigure + update your EEPROM.
  * Download `recovery.bin`
  * Build an sdcard with `recovery.bin`
  * 

1. Install Tow-Boot onto a microSD Card.

2. Boot whatever aarch64 install media you want and install as normal
  -> this might look like booting nixos into memory and then using
  -> an NVME as install target

## Questions-to-self

1. cross-arch install? determinatesystems/bootspec ?
2. use target-disk mode, does that even do anything for us?
