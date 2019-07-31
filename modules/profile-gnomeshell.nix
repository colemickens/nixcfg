{ config, lib, pkgs, ... }:
with lib;

{
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome3.enable = true;

    environment.systemPackages = with pkgs; [
    ];
  };
}

