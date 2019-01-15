{ config, lib, pkgs, ... }:
with lib;

{
  programs = {
    qt5ct.enable = true; # https://github.com/NixOS/nixpkgs/issues/25762
    sway-beta = {
      enable = true;
      package = pkgs.sway-beta;
      extraSessionCommands = ''
        export SDL_VIDEODRIVER=wayland
        export GDK_BACKEND=wayland
        export QT_QPA_PLATFORM=wayland
        export QT_WAYLAND_DISABLE_WINDOWDECORATION="1"
        export _JAVA_AWT_WM_NONREPARENTING=1
      '';
    };
  };

  environment.systemPackages = with pkgs; [
    swayidle
    i3status-rust
    termite
    xwayland
    pulsemixer
    feh

    gnome3.gcr

    wlroots.examples
    slurp
    grim
    mako
    kanshi
    wlstream
    oguri
    waybar
    redshift-wayland
    weston
    #wmfocus
    wayfire
    wl-clipboard

    # swaylock-fancy-mm
    imagemagick jq
  ];
}

