{ pkgs, lib, modulesPath, inputs, config, ... }:

# from: https://www.raspberrypi.com/documentation/computers/processors.html
#   The Raspberry Pi RP3A0 is our first System-in-Package (SiP) consisting of a
#   Broadcom BCM2710A1 — which is the silicon die packaged inside the Broadcom
#   BCM2837 chip which is used on the Raspberry Pi 3 — along with 512 MB of DRAM.

## RPI3+
## RPI02W

let
  mbr_disk_id = config.system.build.mbr_disk_id;
in
{
  imports = [
    ./rpi-core.nix
    ./rpi-towboot.nix
  ];

  config = {
    nixcfg.common.useZfs = false;
    environment.systemPackages = with pkgs; [ picocom ];

    boot = {
      kernelParams = [
        "cma=128M"
      ];
      kernelModules = [
        # "v3d"
        "r8152"
      ];
      initrd = {
        availableKernelModules = [
          "xhci_pci"
          "xhci_hcd"
          "uas"
          "usb_storage"
          "mmc_block"
          "usbhid"
        ];
        kernelModules = [
          "r8152" # the usb eth adapter using with uboot
          "genet"
          "lan78xx" # rpi3b lan driver
          "brcmfmac" # wifi, maybe remove so fw loads later
          "pcie_brcmstb"
          "broadcom"
          "vc4"
          "v3d"
          "reset_raspberrypi"
          "xhci_pci"
          "sd_mod"
          "usbhid"
          "hid_generic"
          "hid_microsoft"
        ];
      };
    };
  };
}
