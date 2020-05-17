{ config, lib, pkgs, ... }:

with lib;

{
  config = {
    services.nscd.enable = false; # once and for all
    services.resolved.enable = mkForce false;

    environment.systemPackages = with pkgs; [ vim bash ];

    boot = {
      tmpOnTmpfs = true;
      cleanTmpDir = true;
      kernel.sysctl = {
        "fs.file-max" = 100000;
        "fs.inotify.max_user_instances" = 256;
        "fs.inotify.max_user_watches" = 500000;
      };
    };

    # TODO: root ssh config to get nix daemon to use user's gpg-agent for ssh

    nix = {
      buildCores = 0;
      binaryCachePublicKeys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY=" ];
      binaryCaches = [ "https://cache.nixos.org" ];
      trustedUsers = [ "@wheel" "root" ];
    };

    i18n.defaultLocale = "en_US.UTF-8";

    security.sudo.wheelNeedsPassword = false;
    users.mutableUsers = false;
  };
}

