{
  pkgs,
  lib,
  modulesPath,
  inputs,
  config,
  extendModules,
  ...
}:

let
  hn = "h96maxv58";
in
{
  imports = [
    inputs.h96.outputs.nixosModules.base-config
    inputs.h96.outputs.nixosModules.device-tree
    inputs.h96.outputs.nixosModules.mesa-panfork

    ../../profiles/core.nix
    ../../profiles/user-cole.nix

    ../../profiles/gui-sway-auto.nix  
    
    ../../mixins/common.nix
    ../../mixins/iwd-networks.nix
    ../../mixins/tailscale.nix
    ../../mixins/sshd.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";

    nixpkgs.overlays = [
      (final: super: {
        makeModulesClosure = x: super.makeModulesClosure (x // { allowMissing = true; });
      })
    ];

    environment.systemPackages = with pkgs; [
      evtest
      ripgrep
    ];

    nixcfg.common = {
      useZfs = false;
      defaultKernel = false;
    };

    boot.loader.systemd-boot.enable = false;
    networking.wireless.enable = lib.mkForce false;
    networking.wireless.iwd.enable = true;

    networking.hostName = hn;
    system.stateVersion = "23.11";
  };
}
