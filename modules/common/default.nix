{ config, lib, pkgs, ... }:

{
  imports = [
    ./cole.nix
    ./nix.nix
    ./pkgs.nix
    ./mixin-gpg.nix
  ];

  config = {
    boot = {
      tmpOnTmpfs = true;
      cleanTmpDir = true;
      kernel.sysctl = {
        "fs.file-max" = 100000;
        "fs.inotify.max_user_instances" = 256;
        "fs.inotify.max_user_watches" = 500000;
      };
    };

    services = {
      timesyncd.enable = true;
      pcscd.enable = true; # TODO: should be moved to gpg, if not already
      upower.enable = true;
    };

    users.mutableUsers = false;
    security.sudo.wheelNeedsPassword = false;
  };
}


