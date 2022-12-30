{ config, lib, pkgs, ... }:

{
  config = {
    nixpkgs.overlays = [
      (prev: final: {
        libsecret = prev.libsecret.overrideAttrs(old: {
          doCheck = false;
        });
      })
    ];
  };
}
