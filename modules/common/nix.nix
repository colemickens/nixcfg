{ ... }:

let
  useLocal = true;
  over = name: url:
    if useLocal && builtins.pathExists "/etc/nix/overlays/${name}"
    then (import "/etc/nix/overlays/${name}")
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
      #(over "nixpkgs-kubernetes" "https://github.com/colemickens/nixpkgs-kubernetes/archive/master.tar.gz")
      (over "nixpkgs-mozilla" "https://github.com/mozilla/nixpkgs-mozilla/archive/0d64cf67dfac2ec74b2951a4ba0141bc3e5513e8.tar.gz")
    ];
  };

  nix = {
    nixPath = [ "/etc/nixos" "nixpkgs=/etc/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];
    trustedUsers = [ "root" "@wheel" ];
  };
}

