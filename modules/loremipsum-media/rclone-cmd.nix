{ lib, pkgs, ... }:

let
  c = import ./common.nix { inherit pkgs; };
in {
  environment.systemPackages = with pkgs; [
    (pkgs.writeScriptBin "rclone-lim" ''
      #!/usr/bin/env bash
      ${pkgs.rclone}/bin/rclone --config "${c.rcloneConfigFile}" "''${@}"
    '')

    c.rclone-lim-mount
  ];
}

