{ pkgs, lib, config, inputs, ... }:

let
  prefs = import ../../mixins/_preferences.nix { inherit pkgs lib config inputs; };
  useUnstableOverlay = true;
in
{
  imports = [
    ../gui-wayland.nix

    ../../mixins/sway.nix # contains swayidle/swaylock config
  ];
  config = {
    nixpkgs.overlays =
      if useUnstableOverlay then [
        inputs.nixpkgs-wayland.overlay
      ] else [ ];
    security.wrappers = {
      "wshowkeys" = {
        owner = "root";
        group = "root";
        setuid = true;
        source = "${pkgs.wshowkeys}/bin/wshowkeys";
      };
    };

    xdg.portal.enable = true;
    xdg.portal.extraPortals = with pkgs;
      [
        xdg-desktop-portal-wlr
        (xdg-desktop-portal-gtk.override {
          buildPortalsInGnome = false;
        })
      ];

    home-manager.users.cole = { pkgs, ... }: {
      services = {
        udiskie.enable = false;
        # poweralertd.enable = true;
        # wlsunset = {
        #   enable = true;
        #   latitude = "47.608103";
        #   longitude = "-122.335167";
        # };
      };

      home.sessionVariables = {
        XDG_CURRENT_DESKTOP = "sway";
      };
    };
  };
}
