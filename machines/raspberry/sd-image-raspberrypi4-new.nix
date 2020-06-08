{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [
    "${modulesPath}/profiles/base.nix"
  ];
  
  config = {
    boot = {
      loader.grub.enable = false;
      loader.raspberryPi.enable = true;
      loader.raspberryPi.version = 4;
      kernelPackages = pkgs.linuxPackages_rpi4;
      supportedFilesystems = [ "zfs" ];
      initrd.availableKernelModules = [ "xhci_pci" "usb_storage" ];
      kernelModules = [ "xhci_pci" "usb_storage" ];

      consoleLogLevel = lib.mkDefault 7;
    };

    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        fsType = "vfat";
        options = [ "nofail" "noauto" ];
      };
      "/" = {
        device = "tank/root";
        fsType = "zfs";
      };
      "/nix" = {
        device = "tank/nix";
        fsType = "zfs";
      };
      "/persist" = {
        device = "tank/persist";
        fsType = "zfs";
      };
    };
  };
}
