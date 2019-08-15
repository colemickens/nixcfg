{ config, lib, pkgs, ... }:
with lib;

{
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome3.enable = true;

    environment.gnome3.excludePackages = pkgs.gnome3.optionalPackages;
    programs.gnome-documents.enable = false;
    services.gnome3.gnome-remote-desktop.enable = false;
    services.gnome3.gnome-user-share.enable = false;
    programs.gpaste.enable = false;

    programs.file-roller.enable = true;
    programs.gnome-disks.enable = true;
    services.gnome3.gnome-terminal-server.enable = true;

    environment.systemPackages = []
      ++ (with pkgs; [])
      ++ (with pkgs.gnome3; [ gedit ]);
  };
}

