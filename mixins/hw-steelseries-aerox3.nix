{ config, pkgs, ... }:

{
  config = {
    services.udev.packages = with pkgs; [ rivalcfg ];
    home-manager.users.cole = { pkgs, ... }: {
      home.pacakges = with pkgs; [
        rivalcfg
      ];
    };
  };
}
