{ config, pkgs, lib, ... }:

{
  config = {
    networking.networkmanager.plugins = lib.mkForce [];
    nixpkgs.overlays = [
      (final: prev: {
        gnupg23 = prev.gnupg23.override { openldap = null; };
        # openfortivpn = null;
        # networkmanager-fortisslvpn = null;
      })
    ];
  };
}
