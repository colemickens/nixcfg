{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  imports = [
    ../risky/configuration.nix
  ];

  config = {
    networking.hostName = lib.mkForce "risky-cross";
    nixpkgs.crossSystem.system = "riscv64-linux";
  };
}
