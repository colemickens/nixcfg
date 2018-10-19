{ config, lib, pkgs, ... }:

{
  imports = [
    ./cole.nix
    ./nix.nix
    ./pkgs.nix
    ./mixin-yubikey-gpg.nix
  ];

  config = {
    environment.systemPackages = with pkgs; [ libva libva-full libva-utils ];

    boot = {
      tmpOnTmpfs = true;
      cleanTmpDir = true;
      supportedFilesystems = [ "btrfs" ];
      kernel.sysctl = {
        "fs.file-max" = 100000;
        "fs.inotify.max_user_instances" = 256;
        "fs.inotify.max_user_watches" = 500000;
      };
    };

    services = {
      timesyncd.enable = true;
      pcscd.enable = true;
      upower.enable = true;
    };

    users.mutableUsers = false;
    security.sudo.wheelNeedsPassword = false;
  };
}


