rpi luks notes:

https://rr-developer.github.io/LUKS-on-Raspberry-Pi/

TARGET="/dev/disk/by-id/usb-WD_My_Passport_260F_575837324441305052353944-0:0"
sudo /nix/store/392m2gp7l9jqj71ppdm1dv3fd1ab26gh-cryptsetup-2.4.0/bin/cryptsetup \
  --type 'luks2' \
  --cipher 'xchacha20,aes-adiantum-plain64' \
  --hash 'sha256' \
  --iter-time 5000 \
  luksFormat $TARGET \
  --key-size 256 \
  --pbkdf argon2id

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
