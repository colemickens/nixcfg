{ ... }:

let
  useLocal = true;
  over = name: url:
    if useLocal && builtins.pathExists "/home/cole/code/overlays/${name}"
    then (import "/home/cole/code/overlays/${name}")
    else (import (builtins.fetchTarball url));
in
{
  imports = [
    ./nix-caches.nix
  ];

  nixpkgs = {
    config.allowUnfree = true;
    overlays = [
      (over "nixpkgs-wayland" "https://github.com/colemickens/nixpkgs-wayland/archive/master.tar.gz")
      (over "nixpkgs-colemickens" "https://github.com/colemickens/nixpkgs-colemickens/archive/master.tar.gz")
      (over "nixpkgs-mozilla" "https://github.com/mozilla/nixpkgs-mozilla/archive/master.tar.gz")

      #(over "nixpkgs-kubernetes" "https://github.com/colemickens/nixpkgs-kubernetes/archive/master.tar.gz")
      #(over "nixpkgs-mozilla" "https://github.com/mozilla/nixpkgs-mozilla/archive/f61795ea78ea2a489a2cabb27abde254d2a37d25.tar.gz")
    ];
  };

  nix.trustedUsers = [ "root" "@wheel" ];
}

