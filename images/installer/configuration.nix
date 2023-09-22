{ config, pkgs, lib, modulesPath, ... }:

let
  hn = "installer";
in
{
  imports = [
    "${modulesPath}/installer/cd-dvd/installation-cd-minimal.nix"

    ../../profiles/core.nix
  ];

  config = {
    ## <tailscale auto-login-qr>
    services.tailscale.enable = true;
    environment.loginShellInit = ''
      [[ "$(tty)" == "/dev/tty1" || "$(tty)" == "/dev/ttyS0" ]] && (
        sudo tailscale login --qr
      )
    '';
    ## </tailscale auto-login-qr>

    system.stateVersion = "23.11";

    boot.swraid.enable = lib.mkForce false;

    # TODO: remove when not debugging:
    # ref: https://github.com/NixOS/nixpkgs/pull/256709
    # isoImage.squashfsCompression = "none";

    nixpkgs.hostPlatform.system = "x86_64-linux";
    networking.hostName = hn;

    boot.loader.timeout = lib.mkOverride 10 10;
    documentation.enable = lib.mkOverride 10 false;
    documentation.info.enable = lib.mkOverride 10 false;
    documentation.man.enable = lib.mkOverride 10 false;
    documentation.nixos.enable = lib.mkOverride 10 false;

    services.fwupd.enable = lib.mkForce false;

    # BUG not sure if this works, at one point it was claimed it didn't...
    boot.initrd.systemd.enable = lib.mkForce false;

    system.disableInstallerTools = lib.mkOverride 10 false;

    systemd.services.sshd.wantedBy = pkgs.lib.mkOverride 10 [ "multi-user.target" ];
  };
}
