{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

let
  hn = "h96";
  pp = "h96";
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
