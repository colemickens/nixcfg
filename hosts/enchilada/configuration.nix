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

    # N/A on Enchilada
    # mobile.boot.stage-1.kernel.provenance = "mainline";
    
    ## !!!!!!!!!!!!!!!!!!!!!!!!
    # usb0 appears even with this disabled:
    # mobile.boot.stage-1.networking.enable = true;
    ## !!!!!!!!!!!!!!!!!!!!!!!!

    networking = {
      hostName = hostname;
      # wireless.enable = true;
      # wireless.networks."chimera-iot".pskRaw = "61e387f2c2f49c6e266515096d289cedfc1325aa6e17ab72abf25c64e62eb297";
      # interfaces."wlan0".useDHCP = true;

      useDHCP = false;
      interfaces."usb0".ipv4.addresses = [{
        address = "10.99.0.5";
        prefixLength = 24;
      }];
      defaultGateway = "10.99.0.1";
      nameservers = [ "192.168.1.1" ];
    };
  };
}