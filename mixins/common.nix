{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.nixcfg.common;
in
{
  imports = [
    ./nix.nix
  ];

  options = {
    nixcfg.common = {
      defaultKernel = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          ideally, all machines run mainline. this is mostly disabled for mobile-nixos devices
          (also, in most cases linuxPackages could just be overridden directly)
          # TODO: it would be nice if mobile-nixos didn't make me need this...
        '';
      };
      hostColor = lib.mkOption {
        type = lib.types.str;
        default = "grey";
        description = "this is used as a hostname-hint-accent in zellij/waybar/shell prompts";
      };
      defaultTheme = lib.mkOption {
        type = lib.types.str;
        default = "XXX";
        description = ''
            This is the name of an iterm2 theme.
            Used for zellij, helix, sway, mako, etc.
        '';
      };
    };
  };

  config = {
    i18n.defaultLocale = "en_US.UTF-8";

    services.journald.extraConfig = ''
      SystemMaxUse=10M
    '';

    boot = {
      kernelPackages = lib.mkIf cfg.defaultKernel pkgs.linuxPackages_latest;
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

