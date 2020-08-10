{ pkgs, ... }:

{
  config = {
    sops.secrets."cachix.dhall" = {
      owner = "cole";
      group = "cole";
      path = "/home/cole/.config/cachix/cachix.dhall";
    };
  };
}
