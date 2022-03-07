{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ../mixins/gtk.nix

    ../mixins/wlsunset.nix
    ../mixins/mako.nix
    ../mixins/sirula.nix
    ../mixins/sway.nix
    ../mixins/wayfire.nix
    ../mixins/waybar.nix

    ../mixins/wayland-tweaks.nix

    ./gui.nix
  ];
  config = {
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
      [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];

    home-manager.users.cole = { pkgs, ... }: {
      # block auto-sway reload, Sway crashes...
      xdg.configFile."sway/config".onChange = lib.mkForce "";

      services = {
        udiskie = {
          enable = true;
          automount = false;
          tray = "always";
        };
      };

      home.sessionVariables = {
        TERMINAL = "wezterm";
        MOZ_ENABLE_WAYLAND = "1";
        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "sway";
      };
      home.packages = with pkgs; [
        pavucontrol
        sirula

        imv
        grim
        qt5.qtwayland
        slurp
        nwg-launchers
        waypipe
        wayvnc
        wf-recorder
        wl-clipboard
        wlrctl
        wlr-randr
        # wl-gammactl # nixpkgs-wayland only
        # wlvncc # nixpkgs-wayland only
        # wshowkeys # use the wrapper ^
        wtype
        xwayland
        ydotool

        wayfire
      ];
    };
  };
}
