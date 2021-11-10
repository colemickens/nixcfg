{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "rpizerotwo1";
in
{
  imports = [
    ../rpizero1/rpicore.nix
  ];

  config = {

    # ZFS
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-partlabel/NIXOS";
        fsType = "ext4";
      };
    };

    boot = {
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;

      loader.raspberryPi = lib.mkForce {
        enable = false;
        uboot.enable = false;
      };

      loader.generic-extlinux-compatible.enable = true;
      loader.generic-extlinux-compatible.configurationLimit = 5;
    };
    networking.hostName = hostname;

    networking.wireless.networks."chimera-iot".pskRaw
      = "61e387f2c2f49c6e266515096d289cedfc1325aa6e17ab72abf25c64e62eb297";
  };
}
