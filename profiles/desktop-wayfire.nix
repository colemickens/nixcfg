{ pkgs, lib, config, inputs, ... }:

let
  _wfapps = with pkgs; [
    wayfireApplications
    wf-config
  ];
  __wfapps = pkgs.wayfireApplications ++ [ pkgs.wf-config ];
  wfapps = with pkgs; [
    pkgs.wayfireApplications.wayfire
    pkgs.wayfireApplications.wcm
    pkgs.wf-config
    #pkgs.gnome.gnome-disks
  ];
in {
  imports = [
    ../mixins/gtk.nix

    ../mixins/wayland-tweaks.nix

    ./gui.nix
  ];
  config = {
    #nixpkgs.overlays = [
    #  inputs.nixpkgs-wayland.overlay
    #];
    #environment.systemPackages = wfapps;

    xdg.portal.enable = true;
    xdg.portal.gtkUsePortal = true;
    xdg.portal.extraPortals = with pkgs;
      [ xdg-desktop-portal-wlr xdg-desktop-portal-gtk ];

    #services.gnome.gnome-disks.enable = true;
    programs.gnome-disks.enable = true;

    home-manager.users.cole = { pkgs, ... }: {

      home.sessionVariables = {

        MOZ_ENABLE_WAYLAND = "1";

        #WLR_DRM_NO_MODIFIERS = "1";
        # SDL_VIDEODRIVER = "wayland";
        # QT_QPA_PLATFORM = "wayland";
        # QT_WAYLAND_DISABLE_WINDOWDECORATION = "1";
        # _JAVA_AWT_WM_NONREPARENTING = "1";

        #XDG_SESSION_TYPE = "wayland";
        #XDG_CURRENT_DESKTOP = "sway";
        #TERMINAL = "foot";

        #WLR_DRM_NO_MODIFIERS = "1";
        #WLR_DRM_NO_ATOMIC = "1";
      };
      home.packages = with pkgs; [
        pavucontrol
        qjackctl

        sirula

        imv
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
        wlr-randr
        # wl-gammactl # nixpkgs-wayland only
        # wlvncc # nixpkgs-wayland only
        # wshowkeys # use the wrapper ^
        wtype
        xwayland
        ydotool
      ] ++ wfapps;
    };
  };
}
