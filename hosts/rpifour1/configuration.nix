{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "rpifour1";
in
{
  imports = [
    ./core.nix
    #./modules/home-assistant
    #./modules/unifi.nix

    ./services/nginx-svc-netboot.nix
  ];

  config = {
    networking.hostName = lib.mkForce hostname;

    # ZFS
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        fsType = "vfat";
        options = [ "nofail" ];
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
  };
}
