{ pkgs, lib, modulesPath, inputs, config, ... }:

# from: https://www.raspberrypi.com/documentation/computers/processors.html
#   This is the Broadcom chip used in the Raspberry Pi 4 Model B, the Raspberry
#   Pi 400, and the Raspberry Pi Compute Module 4. The architecture of the
#   BCM2711 is a considerable upgrade on that used by the SoCs in earlier
#   Raspberry Pi models. It continues the quad-core CPU design of the BCM2837,
#   but uses the more powerful ARM A72 core.

## RPI4

{
  imports = [
    ./rpi-core.nix
  ];

  # NOTES: rpi4-specific:
  # sudo env \
  #   BOOTFS=/boot/firmware \
  #   FIRMWARE_RELEASE_STATUS=stable \
  #     rpi-eeprom-config --edit
  #

  config = {
    environment.systemPackages = with pkgs; [
      picocom
    ];

    boot.kernelParams = [
      # when (!no ATF and) the passthru dtb, this isnt needed hm
      "earlycon=uart8250,mmio32,0xfe215040"

      "earlyprintk"
      "console=ttyS1,115200"
    ];
    boot.initrd.kernelModules = [ "vc4" "bcm2835_dma" "i2c_bcm2835" ];
    boot.initrd.availableKernelModules = [
      # "pcie_brcmstb" # netboot, does this even make sense?
      # "bcm_phy_lib" # netboot, does this even make sense?
      # "broadcom" # netboot, does this even make sense?
      # "mdio_bcm_unimac" # netboot, does this even make sense?
      # "genet" # netboot, does this even make sense?
      "vc4"
      "reset_raspberrypi" # needed for USB reset, so that USB works in kernel 5.14
      "xhci_pci" # boot-usb
      # "nvme" # boot-nvme
      "uas" # boot-usb-uas
      "usb_storage" # boot-usb
      "sd_mod" # boot-usb
      "mmc_block" # boot-sdcard
      "usbhid" # luks/kb
      "hid_generic" # luks/kb
      "hid_microsoft" # luks/kb
    ];

    # TODO: harmonize filesystems (rpifour1,sinkor), move them here??
    fileSystems = lib.mkDefault { };
  };
}
