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
  imports = [
    ./gui-wayland.nix

    # WARNING, this enables network-manager, ew!
    inputs.nixos-cosmic.nixosModules.default
  ];

  config =
    let
      tty = "tty${toString config.systemd.services.greetd.vt}";
    in
    {
      services.desktopManager.cosmic = {
        enable = true;
      };

      services.displayManager.cosmic-greeter = {
        enable = true;
      };

      services.supergfxd.enable = false;

      environment.systemPackages = with pkgs; [
        cosmic-player
        cosmic-reader
        cosmic-ext-applet-clipboard-manager
        cosmic-ext-applet-emoji-selector
        cosmic-ext-applet-external-monitor-brightness
        cosmic-ext-examine
        cosmic-ext-tweaks
      ];

      networking.networkmanager.enable = false;

      home-manager.users.cole =
        { pkgs, config, ... }@hm:
        {
          home.packages = with pkgs; [
            # cosmic-emoji-picker
          ];

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
