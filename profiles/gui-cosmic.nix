{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

let
  prefs = import ../mixins/_preferences.nix {
    inherit
      inputs
      config
      lib
      pkgs
      ;
  };
in
{
  imports = [ ./gui-wayland.nix ];

  config = let
    tty = "tty${toString config.systemd.services.greetd.vt}";
  in
  {
    services.xserver.desktopManager.cosmic = {
      enable = true;
    };

    services.xserver.displayManager.cosmic-greeter = {
      enable = true;
    };
 
    home-manager.users.cole =
      { pkgs, config, ... }@hm:
      {
        home.packages = with pkgs; [ ];

        home.sessionVariables = {
          # WLR_RENDERER = "vulkan";
          # XDG_CURRENT_DESKTOP = "sway";
        };

        # xdg.portal = {
        #   enable = true;
        #   extraPortals = with pkgs; [
        #     xdg-desktop-portal-gtk
        #     xdg-desktop-portal-wlr
        #   ];
        #   config = {
        #     common = {
        #       default = [ "gtk" ];
        #     };
        #     sway = {
        #       default = [ "gtk" ];
        #       "org.freedesktop.impl.portal.Screencast" = [ "wlr" ];
        #       "org.freedesktop.impl.portal.Screenshot" = [ "wlr" ];
        #     };
        #   };
        #   #   extraPortal = with pkgs; [
        #   #     xdg-desktop-portal-wlr
        #   #     (xdg-desktop-portal-gtk.override {
        #   #       buildPortalsInGnome = false;
        #   #     })
        #   #   ];
        # };
      };
  };
}
