{ ... }:

let
  nixcfg = "/etc/nixcfg";
  result = {
    xeep = (import ./devices/xeep {
      nixpkgs="/etc/nixpkgs-cmpkgs";
    });
    chimera = (import ./devices/chimera {
      nixpkgs=(builtins.fetchTarball "https://github.com/colemickens/nixpkgs/archive/plex.tar.gz");
    });
  }
  // (if ! builtins.pathExists "/etc/nixos/packet" then null else
  {
    packet-kube = (import ./devices/packet-kube {
      nixpkgs="/etc/nixpkgs-kata3";
    });
  });
in
  result
