{ pkgs, lib, inputs, config, ... }:

{
  imports = [
    ../enchilada/configuration.nix
  ];

  config = {
    nixpkgs.crossSystem = {
      config = "aarch64-unknown-linux-gnu";
    };
  };
}
