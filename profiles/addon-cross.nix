{ config, pkgs, lib, ... }:

{
  config = {
    nixpkgs.overlays = [
      (final: prev: rec {
        gnupg23 = final.gnupg23.override { openldap = "foo"; };
        gnupg = gnupg23;
      })
    ];
  };
}
