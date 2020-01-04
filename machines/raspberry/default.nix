{ pkgs, ... }:

{
  imports = [
    ../../modules/mixin-unifi.nix
    ../../modules/mixin-plex-client.nix
    ../../modules/mixin-home-assistant.nix
    ${pkgs.path}/nixos/modules/installer/cd-dvd/sd-image.nix
    ${pkgs.path}/nixos/modules/installer/cd-dvd/sd-image-raspberrypi4.nix
  ];

  # https://github.com/illegalprime/nixos-on-arm/blob/master/images/mini/default.nix
  # 

  config = {
    # run cage with plex-mpv-shim running in fullscreen
  };
}
