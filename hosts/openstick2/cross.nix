{ lib, pkgs, config, inputs, ... }:

{
  imports = [
   ../openstick/cross.nix
  ];

  config = {
    networking.hostName = lib.mkForce "openstick2";
  };
}
