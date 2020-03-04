{ config, lib, pkgs, ... }:
with lib;

let
  overlay = (import ../lib.nix {}).overlay;
in
{
  config = {
    nixpkgs = {
      overlays = [
        (overlay "nixpkgs-wayland")
      ];
    };
    environment.variables.WLR_DRM_NO_MODIFIERS = "1";

    #xdg.portal.enable = true;
    #xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-wlr ];
    #xdg.portal.gtkUsePortal = true;

    programs = {
      qt5ct.enable = true;
      sway = {
        enable = true;
        #wrapperFeatures = { gtk = true; };
        extraSessionCommands = ''
          export SDL_VIDEODRIVER=wayland
          export QT_QPA_PLATFORM=wayland
          export QT_QPA_PLATFORMTHEME=qt5ct
          export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
      };
    };

    programs.seahorse.enable = true;
    services.gnome3.gnome-keyring.enable = true;

    nix = {
      binaryCachePublicKeys = [ "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=" ];
      binaryCaches = [ "https://nixpkgs-wayland.cachix.org" ];
      trustedUsers = [ "@wheel" "root" ];
    };

    environment.systemPackages = with pkgs; [
      intel-gpu-tools # to confirm iris/vaapi usage
      glib # for gsettings, for gtk+wayland+cursor
      xorg.xrdb # for something?
      gnome3.gcr # for gpg pinentry

      udiskie
      termite
      pulsemixer
      ranger
      xwayland # sway

      # nixpkgs-wayland
      bspwc
      cage
      drm_info
      gebaar-libinput
      glpaper
      grim
      i3status-rust
      kanshi
      imv
      mako
      oguri
      redshift-wayland
      rootbar
      slurp
      #sommelier
      swaybg
      swayidle
      swaylock
      waybar
      waypipe
      wayfire
      wayvnc
      wf-config
      wdisplays
      wev
      wf-recorder
      wlay
      wl-clipboard
      wl-gammactl
      wldash
      wlr-randr
      wofi
      wtype
      #wxrc
      xdg-desktop-portal-wlr
    ];
  };
}

