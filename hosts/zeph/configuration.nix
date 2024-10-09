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
    specialisation."cosmic" = {
      inheritParentConfig = false;
      configuration = {
        imports = [
          ./configuration-base.nix
          ../../profiles/gui-sway.nix
          ../../mixins/pam-u2f.nix
        ];
      };
    };
  };
}
