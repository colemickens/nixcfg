{ config, lib, pkgs, inputs, ... }:

with lib;

{
  imports = [
    ./nix.nix
  ];

  config = {
    i18n.defaultLocale = "en_US.UTF-8";

    services.journald.extraConfig = ''
      SystemMaxUse=10M
    '';

    boot = {
      cleanTmpDir = true;
      kernel.sysctl = {
        "fs.file-max" = 100000;
        "fs.inotify.max_user_instances" = 256;
        "fs.inotify.max_user_watches" = 500000;
      };
    };

    environment.systemPackages = with pkgs; [ coreutils ];

    security.sudo.wheelNeedsPassword = false;
    users.mutableUsers = false;
    users.users."root".initialHashedPassword = lib.mkForce "$6$k.vT0coFt3$BbZN9jqp6Yw75v9H/wgFs9MZfd5Ycsfthzt3Jdw8G93YhaiFjkmpY5vCvJ.HYtw0PZOye6N9tBjNS698tM3i/1";
    users.users."root".hashedPassword = config.users.users."root".initialHashedPassword;

    nixpkgs.overlays = [
      inputs.self.overlay
    ];
  };
}

