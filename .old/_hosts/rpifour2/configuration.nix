{ pkgs, lib, modulesPath, inputs, ... }:

let
  hostname = "rpifour2";
in {
  imports = [
    ../rpifour1/core.nix
    ./services.nix
  ];

  config = {
    # these just override some things from rpione

    networking.hostName = lib.mkForce hostname;
    networking.hostId = lib.mkForce "d00db00f";
    networking.interfaces."eth0".ipv4.addresses = lib.mkForce [{
      address = "192.168.1.3";
      prefixLength = 16;
    }];
    networking.nameservers = [ "192.168.1.1" ];

    fileSystems = lib.mkForce {
      "/boot" = {
        # sudo mkfs.vfat /dev/disk/by-partlabel/rpi2-boot
        device = "/dev/disk/by-partlabel/rpi2-boot";
        fsType = "vfat";
        options = [ "nofail" ];
      };
      "/" = {
        device = "/dev/disk/by-partlabel/rpi2-boot";
        fsType = "ext4";
      };
    };

    # TODO:
    # swapDevices = [{ device = "/dev/disk/by-partlabel/rpi2-swap"; }];

    boot.loader.raspberryPi.firmwareConfig = ''
      dtoverlay=disable-wifi
      dtoverlay=disable-bt
    '';
  };
}
