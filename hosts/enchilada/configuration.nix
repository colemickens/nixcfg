{ pkgs, lib, inputs, config, ... }:
let
  hostname = "enchilada";
in
{
  imports = [
    ../../profiles/phone.nix

    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "oneplus-enchilada";
    })
  ];

  config = {
    system.stateVersion = "21.05";
    mobile.device.serial = "b205392d";

    networking = {
      hostName = hostname;
      wireless.enable = true;
      wireless.networks."chimera-iot".pskRaw = "61e387f2c2f49c6e266515096d289cedfc1325aa6e17ab72abf25c64e62eb297";
      interfaces."wlan0".useDHCP = true;
    };
  };
}