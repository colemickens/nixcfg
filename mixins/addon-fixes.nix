{
  config,
  lib,
  pkgs,
  ...
}:

{
  config = {
    nixpkgs.overlays = [
      (final: prev: {
        libsecret = prev.libsecret.overrideAttrs (old: {
          doCheck = false;
        });
      })
    ];
  };
}
