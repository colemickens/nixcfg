{ ... }:

let
  _nixpkgs = "/etc/nixpkgs-cmpkgs";
  _nixoscfg = "/etc/nixcfg/devices/xeep/default.nix";

  system = import "${_nixpkgs}/nixos" {
    system = "x86_64-linux";

    configuration = {
      imports = [
        _nixoscfg
      ];
    };
  };

  #nixpkgs = import _nixpkgs { config = cfg.config; };

  #mkMachine1 = c: (nixos { configuration = c; }).system;

  #mkMachine2 = c: (import "${nixpkgs}/nixos/lib/eval-config.nix" {
  #  inherit (nixpkgs) system;
  #  modules = [ cfg ];
  #}).config.system.build.toplevel;

  #pkgs = import nixpkgs {};
  #patches = import ./xeep/patches.nix { inherit pkgs; };
  #result = {
  #  xeep = (mkMachine2 ./xeep/default.nix);
  #};
in
  system.config.system.build.toplevel
  #cfg.config.system.build.toplevel

