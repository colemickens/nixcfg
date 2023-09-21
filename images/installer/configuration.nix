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
    system.stateVersion = "23.11";
    boot.swraid.enable = lib.mkForce false;

    nixpkgs.hostPlatform.system = "x86_64-linux";
    networking.hostName = hn;

    boot.loader.timeout = lib.mkOverride 10 10;
    documentation.enable = lib.mkOverride 10 false;
    documentation.nixos.enable = lib.mkOverride 10 false;

    # BUG not sure if this works, at one point it was claimed it didn't...
    boot.initrd.systemd.enable = lib.mkForce false;

    system.disableInstallerTools = lib.mkOverride 10 false;

    systemd.services.sshd.wantedBy = pkgs.lib.mkOverride 10 [ "multi-user.target" ];
  };
}
