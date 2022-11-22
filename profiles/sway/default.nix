{ pkgs, lib, config, inputs, ... }:

let
  prefs = import ../../mixins/_preferences.nix { inherit pkgs lib config inputs; };
  useUnstableOverlay = true;

  out_aw3418dw = "Dell Inc. Dell AW3418DW #ASPD8psOnhPd";
  out_aw2521h = "Dell Inc. Dell AW2521H #HLAYMxgwABDZ";
  out_raisin = "Unknown 0x1402 0x00000000";
  out_carbon = "SDC 0x4152 Unknown";
  
  wlproxylaunch = pkgs.writeShellScriptBin "wlproxylaunch" ''
    pkill -9 -f wayland-proxy-virtwl
    ${pkgs.wayland-proxy-virtwl}/bin/wayland-proxy-virtwl \
      --wayland-display=wayland-2 \
      --xwayland-binary=${pkgs.xwayland}/bin/Xwayland \
      --x-display=2 \
      --verbose &
    
    sleep 1
    echo
    echo "Ready! Example usage (in a new terminal):" >&2
    echo " \$ export WAYLAND_DISPLAY=wayland-2; export DISPLAY=:2" >&2
    echo " \$ ledger-live-desktop # for example" >&2
    echo
    wait
  '';
in
{
  imports = [
    ../gui.nix

    ../../mixins/gtk.nix

    ../../mixins/mako.nix
    ../../mixins/sirula.nix
    ../../mixins/sway.nix # contains swayidle/swaylock config
    ../../mixins/waybar.nix

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
          systemdTarget = "graphical-session.target";
          profiles = {
            "docked".outputs = [
              { criteria = "eDP-1"; status = "disable"; }
              { criteria = "DP-5"; position = "0,0"; }
              # { criteria = out_carbon; status = "disable"; }
              # { criteria = out_aw3418dw; position = "1920,0"; }
              # { criteria = out_aw2521h; position = "0,0"; }
            ];
            "docked2".outputs = [
              { criteria = "eDP-1"; status = "disable"; }
              { criteria = "DP-6"; position = "0,0"; }
            ];
            "docked3".outputs = [
              { criteria = out_carbon; status = "disable"; }
              { criteria = out_aw3418dw; position = "0,0"; }
            ];
            "undocked".outputs = [
              { criteria = "eDP-1"; status = "enable"; }
              # { criteria = out_carbon; status = "enable"; }
            ];
          };
        };
        # poweralertd.enable = true;
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
        # audio cli/gui tools
        pulseaudio
        pavucontrol
        
        # wayland env requirements
        qt5.qtwayland
        qt6.qtwayland

        # wayland adjacent
        shotman
        sirula # launcher
        wayprompt
        wlproxylaunch
        wf-recorder
        wl-clipboard
        wlr-randr
        wofi # (wofi-emoji in sway config, needs it)
        wtype
        # wlrctl # fucking awful UX, port to Rust
        # wdisplays # use the CLI
        # ydotool # requires a daemon for some reason? why doesn't wlrctl?

        # misc utils
        imv
        grim
        slurp
      ];
    };
  };
}
