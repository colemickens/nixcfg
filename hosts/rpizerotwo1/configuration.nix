{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ../rpifour1/core.nix
  ];

  config = {
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-partlabel/NIXOS";
        fsType = "ext4";
      };
    };

    networking = {
      hostId = "deadb00e";
      hostName = "rpizerotwo1";
      wireless.enable = true;
      wireless.networks."chimera-iot".pskRaw
        = "61e387f2c2f49c6e266515096d289cedfc1325aa6e17ab72abf25c64e62eb297";
    };
  };
}
