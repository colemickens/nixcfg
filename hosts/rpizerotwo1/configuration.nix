{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "repizerotwo1";
in
{
  imports = [
    ../rpizero1/configuration.nix
  ];

  config = {
    networking.hostName = lib.mkForce hostname;
  };
}
