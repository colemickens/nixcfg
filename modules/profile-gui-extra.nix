{ config, lib, pkgs, ... }:

with lib;

{
  config = { 
    environment.systemPackages = with pkgs; [
      #arc-icon-theme
      #numix-icon-theme

      #numix-cursor-theme
      #capitaine-cursors
      #bibata-cursors
    ];
  };
}

