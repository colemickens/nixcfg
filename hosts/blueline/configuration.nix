{ pkgs, lib, inputs, config, ... }:

let
  hostname = "blueline";
in
{
  imports = [
    ../../profiles/phone.nix

    (import "${inputs.mobile-nixos}/lib/configuration.nix" {
      device = "google-blueline";
    })
  ];

  config = {
    nixcfg.common.defaultKernel = false;
      
    system.stateVersion = "21.05";
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "google-blueline-firmware"
    ];
    # mobile.device.serial = "89WX0J2GL";

#    mobile.boot.stage-1.kernel.provenance = "mainline";

    ## !!!!!!!!!!!!!!!!!!!!!!!!
    # usb0 never appears with this disabled:
#    mobile.boot.stage-1.networking.enable = true;
    ## !!!!!!!!!!!!!!!!!!!!!!!!

    networking = {
      hostName = hostname;
      # wireless.enable = true;
      # wireless.networks."chimera-iot".pskRaw = "61e387f2c2f49c6e266515096d289cedfc1325aa6e17ab72abf25c64e62eb297";
      # interfaces."wlan0".useDHCP = true;

      useDHCP = false;
      interfaces."usb0".ipv4.addresses = [{
        address = "10.88.0.5";
        prefixLength = 24;
      }];
      defaultGateway = "10.88.0.1";
      nameservers = [ "192.168.1.1" ];
    };
  };
}
