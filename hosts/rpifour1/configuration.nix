{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ./core.nix
  ];

  config = {
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        fsType = "vfat";
        options = [ "nofail" ];
      };
      "/boot/firmware" = {
        # the fucking dev name changes depending on how I boot (likely due to diffs in DTBs/bootloader-dtb-loading)
        device = "/dev/disk/by-partuuid/ce8f2026-17b1-4b5b-88f3-3e239f8bd3d8";
        fsType = "vfat";
        options = [ "nofail" "ro" ];
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
    networking = {
      hostId = "deadb00f";
      hostName = "rpifour1";

      wireless.enable = false;
      wireless.iwd.enable = false;

      interfaces."eth0".ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 16;
      }];
      defaultGateway = "192.168.1.1";
      nameservers = [ "192.168.1.1" ];
    };
    boot = {
      kernelParams = [ # when (!no ATF and) the passthru dtb, this isnt needed hm
        "earlycon=uart8250,mmio32,0xfe215040"

        "earlyprintk"
        "console=ttyS1,115200"
        "console=tty1"
        "console=ttyS0,115200"
      ];
      initrd.supportedFilesystems = [ "zfs" ];
      supportedFilesystems = [ "zfs" ];
    };
  };
}
