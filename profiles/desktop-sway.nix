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
    home-manager.users.cole = { pkgs, ... }: {

      # block auto-sway reload, Sway crashes...
      xdg.configFile."sway/config".onChange = lib.mkForce "";

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
        #drm_info
        grim
        qt5.qtwayland
        slurp
        udiskie
        nwg-launchers
        wayvnc
        wf-recorder
        wl-clipboard
        wl-gammactl
        wlvncc
        #wshowkeys # broken
        xwayland
      ];
    };
  };
}
