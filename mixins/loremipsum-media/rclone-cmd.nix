{ lib, pkgs, ... }:

let
  c = import ./common.nix { inherit pkgs; };
in {
  environment.systemPackages = with pkgs; [
    c.rclone-lim
    c.rclone-lim-mount
    c.rclone-lim-mount-all
  ];
}

