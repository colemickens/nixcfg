{ ... }:

let
  #_nixpkgs = "/etc/nixpkgs-cmpkgs";
  #_nixoscfg = "/etc/nixcfg/devices/xeep/default.nix";
  #_system = "x86_64-linux";

  mkMachine = _nixpkgs: _nixoscfg: _system:
  let 
    system = import "${_nixpkgs}/nixos" {
      system = _system;
  
      # these two seem to work the same:
      #configuration = _nixoscfg;
      configuration = { imports = [ _nixoscfg ]; };
    };
  
    pkgs = import _nixpkgs {
      system = _system;
      inherit (ccc.config.nixpkgs) config overlays;
    };
  
    ccc = import "${_nixpkgs}/nixos/lib/eval-config.nix" {
      inherit (pkgs) system;
      inherit pkgs;
      modules = [ _nixoscfg ];
    };
  in
    ccc.config.system.build.toplevel;

  result = {

    xeep = (mkMachine
      "/etc/nixpkgs-cmpkgs"
      "/etc/nixcfg/devices/xeep/default.nix"
      "x86_64-linux");

    packet-kube = (mkMachine
      "/etc/nixpkgs-kata3"
      "/etc/nixcfg/devices/packet-kube/configuration.nix"
      "x86_64-linux");

  };
in
  result

