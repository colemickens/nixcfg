{ config, lib, pkgs, ... }:

with lib;

let
  spkgs = (import /etc/nixpkgs-sway/default.nix {
    config = config.nixpkgs.config;
  }).pkgs;
in
{
  programs = {
    sway = {
      enable = true;
      package = spkgs.sway;
    };
  };

  environment.systemPackages = with pkgs; [
    # tiling wm specific
    i3status-rust
    termite
    rofi
    xwayland
    pulsemixer
    feh

    spkgs.wlroots
    spkgs.redshift-wayland
    spkgs.slurp
    spkgs.grim
    spkgs.waybar
    spkgs.wlstream
    way-cooler
  ];
}

