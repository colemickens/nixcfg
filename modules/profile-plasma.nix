{ config, lib, pkgs, ... }:
with lib;

{
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.sddm.enable = true;
    services.xserver.desktopManager.plasma5.enable = true;

    environment.systemPackages = with pkgs; [
    ];
  };
}

