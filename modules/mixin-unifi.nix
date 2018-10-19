{ pkgs, ... }:

{
  services = {
    unifi = {
      unifiPackage = pkgs.unifiStable;
      enable = true;
    };
  };
}

