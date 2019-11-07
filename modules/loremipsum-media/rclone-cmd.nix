{ lib, pkgs, ... }:

let
  rcloneConfigFile = pkgs.substituteAll {
    src = ./rclone.conf;
    rcloneServiceAccountFile = ./rclone-google-sa.json;
  };
  localData = "/var/lib/data-local";
  rcloneTgt = "google_drive_media_mnt:";
  rcloneMnt = "/var/lib/data";
in {
  environment.systemPackages = with pkgs; [
    (pkgs.writeScriptBin "rclone-lim" ''
      #!/usr/bin/env bash
      rclone --config "${rcloneConfigFile}" "''${@}"
    '')
  ];
}

