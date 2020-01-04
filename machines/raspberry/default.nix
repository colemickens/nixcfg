{ pkgs, modulesPath, ... }:

let lib = pkgs.lib; in
{
  imports = [
    ../../modules/common.nix
    ../../modules/profile-interactive.nix

    #../../modules/mixin-unifi.nix
    ../../modules/mixin-plex-client.nix
    ../../modules/mixin-home-assistant.nix
    ../../modules/user-cole.nix
    "${modulesPath}/installer/cd-dvd/sd-image-raspberrypi4-new.nix"
  ];

  config = {
    services.openssh.enable = lib.mkForce true;

    networking.hostName = "raspberry";

    fileSystems = lib.mkForce {
      "/boot" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        # we NEED this mounted
      };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };
    };
  };
}
