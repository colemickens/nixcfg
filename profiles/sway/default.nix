{ pkgs, lib, config, inputs, ... }:

let
  prefs = import ../../mixins/_preferences.nix { inherit pkgs lib config inputs; };
  useUnstableOverlay = true;

  out_aw3418dw = "Dell Inc. Dell AW3418DW #ASPD8psOnhPd";
  out_aw2521h = "Dell Inc. Dell AW2521H #HLAYMxgwABDZ";
  out_raisin = "Unknown 0x1402 0x00000000";
  out_carbon = "SDC 0x4152 Unknown";
in
{
  imports = [
    ../gui.nix

    ../../mixins/gtk.nix

    ../../mixins/mako.nix
    ../../mixins/sirula.nix
    ../../mixins/sway.nix # contains swayidle/swaylock config
    ../../mixins/waybar.nix
    ../../mixins/wayland-tweaks.nix

    inputs.hyprland.nixosModules.default
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

    programs.hyprland = {
      # enable = true;
      # extraPackages = lib.mkForce [];
    };

    xdg.portal.enable = true;
    xdg.portal.gtkUsePortal = true;
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
        # udiskie = {
        #   enable = true;
        #   automount = false;
        #   tray = "always";
        # };
        kanshi = {
          enable = true;
          profiles = {
            "docked".outputs = [
              { criteria = "eDP-1"; status = "disable"; }
              { criteria = "DP-5"; position = "1920,0"; }
              { criteria = "DP-2"; position = "0,0"; }
              # { criteria = out_carbon; status = "disable"; }
              # { criteria = out_aw3418dw; position = "1920,0"; }
              # { criteria = out_aw2521h; position = "0,0"; }
            ];
            "undocked".outputs = [
              { criteria = "eDP-1"; status = "enable"; }
              # { criteria = out_carbon; status = "enable"; }
            ];
          };
        };
        poweralertd.enable = true;
        wlsunset = {
          enable = true;
          latitude = "47.608103";
          longitude = "-122.335167";
        };
      };

      home.sessionVariables = {
        TERMINAL = prefs.default_term;
        MOZ_ENABLE_WAYLAND = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "sway";
      };
      home.packages = with pkgs; [
        # pulseaudio
        pavucontrol
        #lxqt.pavucontrol-qt
        sirula

        # file managers TODO: pick one?
        # xfce.thunar
        # gnome.nautilus


        # swappy # um, who the fuck comes up with these stupid UX decisions in the sway-adjacent universe?
        pinta
        imv
        grim
        qt5.qtwayland
        slurp
        waypipe
        wayvnc
        wf-recorder
        wl-clipboard
        wlrctl
        wlr-randr
        wdisplays
        # wl-gammactl # nixpkgs-wayland only
        # wlvncc # nixpkgs-wayland only
        # wshowkeys # use the wrapper ^
        wtype
        ydotool
      ];
    };
  };
}
