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
    system.build.android-serial = "b205392d";

    mobile.system.android.boot_partition_destination = "boot_a";
    mobile.system.android.system_partition_destination = "userdata";
    #mobile.system.android.system_partition_destination = "system_a";
    
    ## !!!!!!!!!!!!!!!!!!!!!!!!
    # usb0 appears even with this disabled:
    # mobile.boot.stage-1.networking.enable = true;
    ## !!!!!!!!!!!!!!!!!!!!!!!!

    networking.hostName = hostname;
  };
}