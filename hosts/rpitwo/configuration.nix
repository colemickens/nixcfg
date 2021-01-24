{ pkgs, lib, modulesPath, inputs, ... }:

let
  hostname = "rpitwo";
in {
  imports = [
    ../rpione/core.nix
  ];
  config = {
    networking.hostName = lib.mkForce hostname;
    networking.hostId = lib.mkForce "d00db00f";
    networking.interfaces."eth0".ipv4.addresses = lib.mkForce [{
      address = "192.168.1.3";
      prefixLength = 16;
    }];
    networking.nameservers = [ "192.168.1.1" ];

    fileSystems = lib.mkForce {
      "/boot" = {
        device = "/dev/disk/by-partlabel/rpi2-boot";
        fsType = "vfat";
        options = [ "nofail" ];
      };
      "/" = {
        device = "rpool/root";
        fsType = "zfs";
      };
      "/nix" = {
        device = "rpool/nix";
        fsType = "zfs";
      };
    };

    boot.loader.raspberryPi.firmwareConfig = ''
      dtoverlay=disable-wifi
      dtoverlay=disable-bt
    ''; # TODO: check this gets merged?
  };
}
