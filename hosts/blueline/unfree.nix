{ pkgs, lib, inputs, config, ... }:

{
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "google-blueline-firmware"
    ];
  };
}
