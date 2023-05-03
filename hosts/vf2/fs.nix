{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  pp = "vf2";
in
{
  imports = [
  ];
  config = {
    fileSystems = {
      # "/efi" = {
      #   fsType = "vfat";
      #   device = "/dev/disk/by-partlabel/${pp}-efi";
      # };
      # "/boot" = {
      #   fsType = "vfat";
      #   device = "/dev/disk/by-partlabel/${pp}-boot";
      # };
      "/" = {
        fsType = "btrfs";
        device = "/dev/disk/by-partlabel/${pp}-nixos";
      };

      "/mnt/sdcard" = {
        fsType = "ext4";
        device = "/dev/disk/by-partlabel/vf2-sdcard-root";
      };

      "/boot" = {
        device = "/mnt/sdcard/boot";
        options = [ "bind" ];
      };

      # "/efi/EFI/Linux" = { device = "/boot/EFI/Linux"; options = [ "bind" ]; };
      # "/efi/EFI/nixos" = { device = "/boot/EFI/nixos"; options = [ "bind" ]; };
    };
    swapDevices = [];
    # TODO: partlabel doesn't work for swap?
    # swapDevices = [ "/dev/disk/by-partlabel/${pp}-swap";
  };
}
