{
  pkgs,
  lib,
  modulesPath,
  ...
}:

{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"
    ../../profiles/core.nix
  ];

  config = {
    networking.hostName = "installer";

    nixcfg.common.skipMitigations = true;
    nixcfg.common.defaultKernel = true;

    system.stateVersion = "26.05";

    boot.swraid.enable = lib.mkForce false;

    boot.loader.timeout = lib.mkOverride 10 10;

    documentation.enable = lib.mkOverride 10 false;
    documentation.info.enable = lib.mkOverride 10 false;
    documentation.man.enable = lib.mkOverride 10 false;
    documentation.nixos.enable = lib.mkOverride 10 false;

    services.udisks2.enable = lib.mkForce false;
    networking.modemmanager.enable = lib.mkForce false;

    services.fwupd.enable = lib.mkForce false;

    system.disableInstallerTools = lib.mkOverride 10 false;

    ## <tailscale auto-login>
    systemd.services.sshd.wantedBy = pkgs.lib.mkOverride 10 [ "multi-user.target" ];

    services.tailscale = {
      enable = true;
      extraDaemonFlags = [ "--state=mem:" ];
    };
    environment.loginShellInit = ''
      [[ "$(tty)" == "/dev/tty1" || "$(tty)" == "/dev/ttyS0" ]] && (
        if curl --max-time 10 'https://tailscale.com'; then
          echo "trying to connect to tailscale" &>2
          sudo tailscale login --qr
        else
          echo "no internet connection, skipping tailscale qr login" &>2
        fi
      )
    '';
    services.getty.autologinUser = lib.mkForce "cole";
    ## </tailscale auto-login>
  };
}
