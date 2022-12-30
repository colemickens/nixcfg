{ config, pkgs, lib, ... }:

{
  config = {
    nixpkgs.overlays = [
        (prev: final: {
          gnupg = prev.gnupg.override { openldap = null; };
        })
    ];
  };
}
