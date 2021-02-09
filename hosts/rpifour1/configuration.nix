{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "rpifour1";
in
{
  imports = [
    ./core.nix
    ./modules/home-assistant
    ./modules/nginx.nix
    ./modules/postgres.nix
    ./modules/srht-cronjobs.nix
    ./modules/unifi.nix

    ../../mixins/avahi-publish.nix
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
      # sudo zfs create -o mountpoint=none tank/var
      "/var/lib/unifi" = {
        # sudo zfs create -o mountpoint=legacy tank/var/unifi
        device = "tank/var/unifi";
        fsType = "zfs";
      };
      "/var/lib/hass" = {
        # sudo zfs create -o mountpoint=legacy tank/var/hass
        device = "tank/var/hass";
        fsType = "zfs";
      };
    };
  };
}
