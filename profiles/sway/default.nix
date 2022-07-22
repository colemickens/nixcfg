{ pkgs, lib, config, inputs, ... }:

let
  prefs = import ../../mixins/_preferences.nix { inherit pkgs lib config inputs; };
  useUnstableOverlay = true;
in {
  imports = [
    ../gui.nix

    ../../mixins/gtk.nix

    ../../mixins/mako.nix
    ../../mixins/sirula.nix
    ../../mixins/sway.nix # contains swayidle/swaylock config
    ../../mixins/waybar.nix
    ../../mixins/wayland-tweaks.nix
  ];
  config = {
    nixpkgs.overlays = if useUnstableOverlay then [
      inputs.nixpkgs-wayland.overlay
    ] else [];
    security.wrappers = {
      "wshowkeys" = {
        owner = "root";
        group = "root";
        setuid = true;
        source = "${pkgs.wshowkeys}/bin/wshowkeys";
      };
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
        udiskie = {
          enable = true;
          automount = false;
          tray = "always";
        };
        kanshi.enable = true;
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
