{ config, lib, pkgs, modulesPath, ... }:

let
  moduleList = [
    # cargo culted:
    "pcie_brcmstb" "bcm_phy_lib" "broadcom" "mdio_bcm_unimac" "genet"
    "vc4" "bcm2835_dma" "i2c_bcm2835" # Allows early (earlier) modesetting for the Raspberry Pi

    # try enable usb storage?
    "xhci_pci" "usb_storage"
  ];
in {
  imports = [
    "${modulesPath}/profiles/base.nix"
  ];

  config = {
    boot = {
      loader.grub.enable = false;
      loader.raspberryPi.enable = true;
      loader.raspberryPi.version = 4;
      #kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_rpi4;
      loader.raspberryPi.uboot.enable = true;
      loader.raspberryPi.firmwareConfig = ''
        dtoverlay=vc4-fkms-v3d
        dtoverlay=disable-bt
      '';
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;
      supportedFilesystems = [ "zfs" ];
      initrd.availableKernelModules = moduleList;
      kernelModules = moduleList;

      kernelParams = [
        "cma=64M"
        "earlycon=pl011,mmio32,0xfe201000"
        "console=ttyS0,115200n8"
        "console=ttyAMA0,115200n8"
        "console=tty0"
      ];

      consoleLogLevel = lib.mkDefault 7;
    };

    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
      libraspberrypi
    ];

    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        fsType = "vfat";
        options = [ "nofail" ];
      };
      "/" = {
        device = "tank/root";
        fsType = "zfs";
      };
      "/nix" = {
        device = "tank/nix";
        fsType = "zfs";
      };
    };
  };
}
