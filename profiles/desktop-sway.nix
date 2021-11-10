{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ../mixins/wlsunset.nix
    ../mixins/mako.nix
    ../mixins/sway.nix
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
        # udiskie = {
        #   enable = true;
        #   automount = false;
        #   tray = "always";
        # };
      };

      home.sessionVariables = {

        MOZ_ENABLE_WAYLAND = "1";

        #WLR_DRM_NO_MODIFIERS = "1";
        # SDL_VIDEODRIVER = "wayland";
        # QT_QPA_PLATFORM = "wayland";
        # QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        # _JAVA_AWT_WM_NONREPARENTING = "1";

        XDG_SESSION_TYPE = "wayland";
        XDG_CURRENT_DESKTOP = "sway";

        #WLR_DRM_NO_MODIFIERS = "1";
        #WLR_DRM_NO_ATOMIC = "1";
      };
      home.packages = with pkgs; [
        pavucontrol
        qjackctl

        sirula

        #drm_info
        grim
        qt5.qtwayland
        slurp
        nwg-launchers
        waypipe
        wayvnc
        wf-recorder
        wl-clipboard
        wlrctl
        # wl-gammactl # nixpkgs-wayland only
        # wlvncc # nixpkgs-wayland only
        # wshowkeys # use the wrapper ^
        wtype
        xwayland
        ydotool
      ];
    };
  };
}
