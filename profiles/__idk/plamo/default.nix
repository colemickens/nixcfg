{ pkgs, lib, config, inputs, ... }:

{
  config = {
    services.xserver = {
      enable = true;

      displayManager.defaultSession = "plasma-mobile";

      desktopManager.plasma5 = {
        mobile.enable = true;
      };
    };

    hardware.sensor.iio.enable = true; # ?? no idea

    environment.etc."machine-info".text = lib.mkDefault ''
      CHASSIS="handset"
    '';
  };
}
