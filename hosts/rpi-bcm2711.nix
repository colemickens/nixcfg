{ pkgs, lib, modulesPath, inputs, config, ... }:

# from: https://www.raspberrypi.com/documentation/computers/processors.html
#   This is the Broadcom chip used in the Raspberry Pi 4 Model B, the Raspberry
#   Pi 400, and the Raspberry Pi Compute Module 4. The architecture of the
#   BCM2711 is a considerable upgrade on that used by the SoCs in earlier
#   Raspberry Pi models. It continues the quad-core CPU design of the BCM2837,
#   but uses the more powerful ARM A72 core.

## RPI4

let
  mbr_disk_id = config.system.build.mbr_disk_id;
in {
  imports = [
    ./rpi-core.nix
    ./rpi-towboot.nix
  ];
  
  config = {
    environment.systemPackages = with pkgs; [
      picocom
      libraspberrypi
    ];
    hardware.usbWwan.enable = true;

    boot = {
      loader.generic-extlinux-compatible.useGenerationDeviceTree = true;

      kernelParams = [
        "cma=512M"
        "snd_bcm2835.enable_hdmi=1"
        "snd_bcm2835.enable_headphones=0"
      ];
      # initrd.preFailCommands = ''
      #   reboot
      # '';
      initrd.kernelModules = config.boot.initrd.availableKernelModules;
      initrd.availableKernelModules = [
        "genet"
        # "genet" # netboot, does this even make sense?
        # "nvme" # boot-nvme
        "pcie_brcmstb" # boot-usb
        "broadcom" # netboot, does this even make sense?
        "v3d" "vc4" # vc4/hdmi stuffs?
        "reset_raspberrypi" # needed for USB reset, so that USB works in kernel 5.14
        "xhci_pci" # boot-usb
        "uas" # boot-usb-uas
        "usb_storage" # boot-usb
        "sd_mod" # boot-usb
        "mmc_block" # boot-sdcard
        "usbhid" # luks/kb
        "hid_generic" # luks/kb
        "hid_microsoft" # luks/kb
      ];
    };
  };
}
