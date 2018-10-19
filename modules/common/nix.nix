{ ... }:

{
  nixpkgs = {
    config ={
      allowUnfree = true;
    };
    overlays = [
      (import (builtins.fetchTarball {
        url = "https://github.com/stesie/azure-cli-nix/archive/21d92db4d81af549784c8545c40f7a1abdb9c7dd.tar.gz";
	sha256 = "1s9g9g2vifhba0i99dlhppafbiqi9gdyfna2mpgnpkcdp2z3gj2q";
      }))
    ];
  };

  nix = {
    nixPath = [ "/etc/nixos" "nixpkgs=/etc/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];
    binaryCachePublicKeys = [
      "nixcache.cluster.lol-1:DzcbPT+vsJ5LdN1WjWxJPmu+BeU891mgsrRa2X+95XM="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    trustedBinaryCaches = [
      "https://nixcache.cluster.lol"
      "https://cache.nixos.org"
    ];
    binaryCaches = [
      "https://nixcache.cluster.lol"
      "https://cache.nixos.org"
    ];
    trustedUsers = [ "root" "@wheel" ];
  };
}

