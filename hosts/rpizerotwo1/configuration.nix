{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ../rpifour1/core.nix
    ../../mixins/wpa-slim.nix
  ];

  config = {
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-partlabel/NIXOS";
        fsType = "ext4";
      };
    };

    networking = {
      hostName = "rpizerotwo1";
    };
  };
}
