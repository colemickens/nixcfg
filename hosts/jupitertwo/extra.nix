{
  pkgs,
  lib,
  inputs,
  ...
}:

{
  imports = [];

  config = {
    nix.settings = {
      extra-trusted-public-keys = [
        "cache.cum.navy-1:IFGBSHhUYM3c+2sJj0MMwcCG+9bOr5UahzdnPsV9JKA="
      ];
      extra-substituters = [ "https://cache.cum.navy" ];
      extra-trusted-substituters = [ "https://cache.cum.navy" ];
    };
  };
}
