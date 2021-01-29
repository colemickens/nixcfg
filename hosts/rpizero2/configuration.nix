{ pkgs, lib, modulesPath, inputs, ... }:

let
  hostname = "rpizero2";
in {
  imports = [
    ../rpizero1/configuration.nix
  ];

  config = {
    # these just override some things from rpione

    networking.hostName = lib.mkForce hostname;
  };
}
