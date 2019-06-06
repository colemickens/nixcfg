{ config, lib, pkgs, ... }:

with lib;

{
  config = { 
    environment.systemPackages = with pkgs; [
      glib # gsettings for 'sway' to fixup gtk mouse cursors
           # (wtf is there a gtk bug)
      dolphin nautilus

      arc-icon-theme
      numix-icon-theme

      numix-cursor-theme
      capitaine-cursors
      bibata-cursors
    ];
  };
}

