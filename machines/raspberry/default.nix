{ pkgs, modulesPath, ... }:

let lib = pkgs.lib; in
{
  imports = [
    #../../modules/mixin-unifi.nix
    ../../modules/mixin-plex-client.nix
    ../../modules/mixin-home-assistant.nix
    ../../modules/user-cole.nix
    "${modulesPath}/installer/cd-dvd/sd-image-raspberrypi4.nix"
  ];

  config = {
    services.openssh.enable = lib.mkForce true;
  };
}
