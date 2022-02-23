{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "rpithreebp1";
in
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
      hostId = "deadb00d";
      hostName = hostname;

      wireless.enable = false;
      wireless.iwd.enable = false;

      interfaces."eth0".ipv4.addresses = [{
        address = "192.168.1.3";
        prefixLength = 16;
      }];
      defaultGateway = "192.168.1.1";
      nameservers = [ "192.168.1.1" ];
    };
  };
}
