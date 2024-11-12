{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # in configuration.nix, default to cosmic
    ../../profiles/gui-sway.nix
    ./configuration-base.nix
  ];
  config = {
    specialisation."cosmic" = {
      inheritParentConfig = false;
      configuration = {
        imports = [
          ./configuration-base.nix
          ../../profiles/gui-cosmic.nix
        ];
      };
    };
    # specialisation."gamescope" = {
    #   inheritParentConfig = false;
    #   configuration = {
    #     imports = [
    #       ./configuration-base.nix
    #       ../../profiles/gui-gamescope.nix
    #     ];
    #   };
    # };
  };
}
