{ pkgs, lib, inputs, config, ... }:

{
  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "openstick-firmware"
      "openstick-firmware-xz"
      "uf896_v1_1_ogfw"
    ];
  };
}
