{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./gui.nix
  ];
  config = {
    environment.pathsToLink = [ "/libexec" ]; # links /libexec from derivations to /run/current-system/sw 

    systemd.services."display-manager".wantedBy = lib.mkForce [ ];

    services.xserver = {
      enable = true;
      autorun = false;

      desktopManager = {
        xterm.enable = false;
      };

      displayManager = {
        defaultSession = "none+i3";
      };

      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          dmenu #application launcher most people use
          i3status # gives you the default i3 status bar
          i3lock #default i3 screen locker
          i3blocks #if you are planning on using i3blocks over i3status
        ];
      };
    };
  };
}
