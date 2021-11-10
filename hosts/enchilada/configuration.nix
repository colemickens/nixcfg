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

    mobile.system.android.boot_partition_destination = "boot_a";
    mobile.system.android.system_partition_destination = "userdata";
    #mobile.system.android.system_partition_destination = "system_a";
    
    ## !!!!!!!!!!!!!!!!!!!!!!!!
    # usb0 appears even with this disabled:
    # mobile.boot.stage-1.networking.enable = true;
    ## !!!!!!!!!!!!!!!!!!!!!!!!

    networking = {
      hostName = hostname;

      wireless.enable = true;
      wireless.networks."chimera-iot".pskRaw = "61e387f2c2f49c6e266515096d289cedfc1325aa6e17ab72abf25c64e62eb297";
      interfaces."wlan0".useDHCP = true;

      # NOTE: tell NM to ignore wlan0 if I'm going to keep using wpa_supplicant for it!

      useDHCP = false;
      interfaces."usb0".ipv4.addresses = [{
        address = "10.99.0.5";
        prefixLength = 24;
      }];

      nameservers = [ "192.168.1.1" ];
    };
  };
}