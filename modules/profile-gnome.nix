{ config, lib, pkgs, ... }:
with lib;

{
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome3.enable = true;

    services.printing.enable = false;

    services.gnome3.core-utilities.enable = false;

    services.colord.enable = true;
    services.gnome3.gnome-remote-desktop.enable = false;
    services.gnome3.gnome-user-share.enable = false;
    services.gvfs.enable = true;
    services.telepathy.enable = false;

    programs.gpaste.enable = false;
    programs.evince.enable = true;
    programs.file-roller.enable = true;
    programs.gnome-documents.enable = false;
    programs.gnome-disks.enable = true;
    programs.gnome-terminal.enable = true;
    programs.seahorse.enable = true;
    services.gnome3.sushi.enable = true;

    environment.systemPackages = []
      ++ (with pkgs; [])
      ++ (with pkgs.gnome3; [ gedit gnome-tweaks ]);
  };
}

