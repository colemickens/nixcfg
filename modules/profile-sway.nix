{ config, lib, pkgs, ... }:
with lib;

{
  programs = {
    qt5ct.enable = true; # https://github.com/NixOS/nixpkgs/issues/25762
    sway-beta = {
      enable = true;
      package = pkgs.sway-beta;
    };
  };

  environment.systemPackages = with pkgs; [
    i3status-rust
    termite
    rofi
    xwayland
    pulsemixer
    feh

    dunst

    #sway-beta (don't mask sway-joined from the module)
    #wlroots.bin
    # TODO: re-enable fater pulling nixpkgs patch for wlroots-ex prefix
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
    wmfocus

    wayfire
  ];
}

