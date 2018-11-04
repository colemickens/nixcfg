{ config, lib, pkgs, ... }:
with lib;

let
  nos = "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz";
  swayOverlay =
    if builtins.pathExists /etc/nix-overlays/nixpkgs-wayland
    then (import /etc/nix-overlays/nixpkgs-wayland)
    else (import (builtins.fetchTarball nos));
in
{
  nixpkgs.overlays = [ swayOverlay ];

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
    way-cooler

    dunst

    #sway-beta (don't mask sway-joined from the module)
    #wlroots.bin
    # TODO: re-enable fater pulling nixpkgs patch for wlroots-ex prefix
    wlroots.examples
    slurp
    grim
    mako
    wlstream
    waybar
    redshift-wayland
    weston

    wayfire
  ];
}

