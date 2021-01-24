{ pkgs, lib, modulesPath, inputs, ... }:

let
  hostname = "rpitwo";
in {
  imports = [
    ../rpione/configuration.nix
  ];
  config = {
    networking.hostName = lib.mkForce hostname;
    networking.hostId = lib.mkForce "d00db00f";
    networking.interfaces."eth0".ipv4.addresses = lib.mkForce [{
      address = "192.168.1.3";
      prefixLength = 16;
    }];

    boot.loader.raspberryPi.firmwareConfig = ''
      dtoverlay=disable-wifi
      dtoverlay=disable-bt
    ''; # TODO: check this gets merged?

    services.home-assistant.enable = lib.mkForce false;
    services.unifi.enable = lib.mkForce false;
  };
}
