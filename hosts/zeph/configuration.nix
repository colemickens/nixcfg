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
    ../../profiles/gui-cosmic.nix
    ./configuration-base.nix
  ];
  config = {
    specialisation."sway" = {
      inheritParentConfig = false;
      configuration = {
        imports = [
          ./configuration-base.nix
          ../../profiles/gui-sway.nix
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
