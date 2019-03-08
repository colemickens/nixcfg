{ config, lib, pkgs, ... }:
with lib;

{
  config = {
    services.xserver = {
      enable = true;
      desktopManager = {
        default = "none";
        xterm.enable = false;
      };
      windowManager.i3.enable = true;
    };

    environment.systemPackages = with pkgs; [
    ];
  };
}

