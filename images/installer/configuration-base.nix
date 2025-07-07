{ pkgs, lib, ... }:

{
  imports = [ ../../profiles/core.nix ];

  config = {

    nixcfg.common.skipMitigations = true;
    nixcfg.common.defaultKernel = true;

    system.stateVersion = "23.11";

    system.nixos.label = "default";

    boot.swraid.enable = lib.mkForce false;

    nixpkgs.hostPlatform.system = "x86_64-linux";

    documentation.enable = lib.mkOverride 10 false;
    documentation.info.enable = lib.mkOverride 10 false;
    documentation.man.enable = lib.mkOverride 10 false;
    documentation.nixos.enable = lib.mkOverride 10 false;

    services.fwupd.enable = lib.mkForce false;

    # BUG not sure if this works, at one point it was claimed it didn't...
    # boot.initrd.systemd.enable = lib.mkForce false;

    system.disableInstallerTools = lib.mkOverride 10 false;

    systemd.services.sshd.wantedBy = pkgs.lib.mkOverride 10 [ "multi-user.target" ];
  };
}
