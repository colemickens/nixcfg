{ pkgs, modulesPath, ... }:

let
  lib = pkgs.lib;
  eth = "eth0";
  wg = "wg1";
in
{
  imports = [
    ../../modules/common.nix
    ../../modules/user-cole.nix
    ../../modules/loremipsum-media/rclone-mnt.nix
    ../../modules/mixin-plex-mpv.nix

    # GUI
    ./kiosk.nix
    #../../modules/profile-sway-minimal.nix
    #../../modules/mixin-nix-gc.nix
  ];

  config = {
    system.build.custom = {
      hardware = "raspberryPi4";
      program = {
        package = pkgs.firefox;
        executable = "/bin/firefox";
      };
      hostName = "couchpie";
      localSystem = { system = builtins.currentSystem; };
    };
  };
}
