{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

let
  hn = "h96maxv58";
  pp = "h96maxv58";
in
{
  config = {
    fileSystems = lib.mkDefault {
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${hn}-boot";
      };
      "/" = {
        fsType = "ext4";
        device = "/dev/disk/by-partlabel/${hn}-nixos";
      };
    };
  };
}
