{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    ../../profiles/interactive.nix
  ];

  config = {
  
    boot.loader.timeout = lib.mkOverride 10 10;
    documentation.enable = lib.mkOverride 10 false;
    documentation.nixos.enable = lib.mkOverride 10 false;

    # this way we have one glorified system that likely covers
    # all of our bases, even if we aren't actively using.
    # mostly a preventative measure, to assist CI in helping me avoid builds
    system.specialisations = {
      "dummy-sway" = {};
      "dummy-hyrpland" = {};
      "dummy-phosh" = {};
      "dummy-etc" = {};
    }
    environment.systemPackages = with pkgs; [
      
    ];
    nixcfg.common.sysdBoot = false;

    system.disableInstallerTools = lib.mkOverride 10 false;

    systemd.services.sshd.wantedBy = pkgs.lib.mkOverride 10 [ "multi-user.target" ];
  };
}
