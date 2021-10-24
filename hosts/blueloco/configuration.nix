{ pkgs, lib, inputs, config, ... }:

{
  imports = [
    ../blueline/configuration.nix
  ];

  config = {
    nixpkgs.crossSystem = {
      config = "aarch64-unknown-linux-gnu";
    };
  };
}
