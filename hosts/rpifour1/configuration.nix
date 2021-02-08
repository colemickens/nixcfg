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

    ../../mixins/avahi-publish.nix
    ../../mixins/srht-cronjobs.nix
    ../../mixins/unifi.nix
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
      # TODO: add datasets for unifi and home-assistant and then add backup jobs
      # TODO: this requires migration before switching to this config
      #    --- plus actually figuring out the backups to make it worth the efforts
    };
  };
}
