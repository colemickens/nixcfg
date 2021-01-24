{ config, lib, pkgs, modulesPath, ... }:

{
  config = {
    boot = {
      loader.grub.enable = true;
      loader.grub.configurationLimit = 1; # TODO: undo when this works!
      loader.grub.devices = [ "nodev" ];
      loader.grub.efiSupport = true;
      loader.grub.efiInstallAsRemovable = true;
      loader.grub.zfsSupport = true;
      loader.grub.extraFiles = {
        "RPI_EFI.fd" = "${pkgs.rpi4-uefi}/RPI_EFI.fd";
        "config.txt" = "${pkgs.rpi4-uefi}/config.txt";
        "fixup4.dat" = "${pkgs.rpi4-uefi}/fixup4.dat";
        "start4.elf" = "${pkgs.rpi4-uefi}/start4.elf";

        "bcm2711-rpi-4-b.dtb" = "${pkgs.rpi4-uefi}/bcm2711-rpi-4-b.dtb";
        "bcm2711-rpi-400.dtb" = "${pkgs.rpi4-uefi}/bcm2711-rpi-400.dtb";
        "bcm2711-rpi-cm4.dtb" = "${pkgs.rpi4-uefi}/bcm2711-rpi-cm4.dtb";
      };
    };
  };
}
