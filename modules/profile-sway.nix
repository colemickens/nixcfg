{ config, lib, pkgs, ... }:
with lib;

let
  nos = "https://github.com/colemickens/nix-overlay-sway/archive/master.tar.gz";
  swayOverlay =
    if builtins.pathExists /etc/nix-overlay-sway
    then (import /etc/nix-overlay-sway)
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

    sway-beta
    wlroots.bin
    slurp
    grim
    wlstream
    waybar
    redshift-wayland
  ];
}

