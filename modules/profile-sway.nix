{ config, lib, pkgs, ... }:
with lib;

let
  overlay = (import ../lib.nix {}).overlay;
in
{
  config = {
    nixpkgs = {
      overlays = [
        (overlay
          "nixpkgs-wayland"
          "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz")
      ];
    };
    programs = {
      qt5ct.enable = true;
      sway = {
        enable = true;
        extraSessionCommands = ''
          export SDL_VIDEODRIVER=wayland
          export GDK_BACKEND=wayland
          export QT_QPA_PLATFORM=wayland
          export QT_QPA_PLATFORMTHEME=qt5ct
          export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
          export _JAVA_AWT_WM_NONREPARENTING=1
        '';
      };
    };

    nix = {
      binaryCachePublicKeys = [ "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA=" ];
      binaryCaches = [ "https://nixpkgs-wayland.cachix.org" ];
      trustedUsers = [ "@wheel" "root" ];
    };

    environment.systemPackages = with pkgs; [
      obs-studio
      wlrobs
      gnome3.gcr

      swaybg
      swayidle
      swaylock

      udiskie
      termite
      pulsemixer
      feh
      ranger

      i3status-rust
      xwayland

      wlroots.examples
      slurp
      grim
      mako
      kanshi
      oguri
      waybar
      redshift-wayland
      wayfire
      wl-clipboard
      wf-recorder
      glpaper

      gebaar-libinput
    ];
  };
}

