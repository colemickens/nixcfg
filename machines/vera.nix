{ config, lib, stdenv, pkgs, ... }:

let
  hostname = "vera";
  nixosHardware = builtins.fetchTarball
    "https://github.com/NixOS/nixos-hardware/archive/master.tar.gz";in
{
  imports = [
    ../modules/common.nix

    ../modules/mixin-samba.nix
    ../modules/mixin-sshd.nix
    ../modules/mixin-unifi.nix
    ../modules/mixin-loremipsum-media.nix

    ../modules/user-cole.nix

    "${builtins.toString nixosHardware}/common/pc"
  ];

  config = {
    ## minimal
    #environment.noXlibs = true; # TODO!!
    i18n.supportedLocales = [ (config.i18n.defaultLocale + "/UTF-8") ];
    documentation.enable = false;
    documentation.nixos.enable = false;

    system.stateVersion = "19.03";
    
    time.timeZone = "America/Los_Angeles";
    services.timesyncd.enable = true;
    services.resolved.enable = true;
    nixpkgs.config.allowUnfree = true;
    
    networking.hostId = "dead4ef4";
    networking.hostName = hostname;
    networking.firewall.enable = true;

    virtualisation.hypervGuest.enable = true;

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-label/nixos";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-label/ESP";
        fsType = "vfat";
      };
      "/media/data" = {
        device = "/dev/disk/by-id/scsi-350014e2eb4b14716";
        fsType = "btrfs";
      };
      #"/var/lib/data" = {
      #  device = "/dev/disk/by-id/scsi-350014e2eb4b14716";
      #  fsType = "btrfs"; options = "subvol=var-lib-data";
      #};
      #"/var/lib/transmission" = {
      #  device = "/dev/disk/by-id/scsi-350014e2eb4b14716";
      #  fsType = "btrfs"; options = "subvol=var-lib-transmission";
      #};
      #"/var/lib/unifi" = {
      #  device = "/dev/disk/by-id/scsi-350014e2eb4b14716";
      #  fsType = "btrfs"; options = "subvol=var-lib-unifi";
      #};
    };
    
    swapDevices = [];
    
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.loader.grub.enable = true;
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.device = "nodev";
  };
}

