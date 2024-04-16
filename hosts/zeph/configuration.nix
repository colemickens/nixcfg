{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [
    # in configuration.nix, default to sway
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
  };
}
