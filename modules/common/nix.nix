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
    binaryCachePublicKeys = [
      "nix-cache.cluster.lol-1:Pa4IudNcMNF+S/CjNt5GmD8vVJBDf8mJDktXfPb33Ak="
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    ];
    trustedBinaryCaches = [
      "https://kixstorage.blob.core.windows.net/nixcache"
      "https://cache.nixos.org"
    ];
    binaryCaches = [
      "https://kixstorage.blob.core.windows.net/nixcache"
      "https://cache.nixos.org"
    ];
    trustedUsers = [ "root" "@wheel" ];
  };
}

