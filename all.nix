{ ... }:

let
  _nixpkgs = "/etc/nixpkgs-cmpkgs";
  _nixoscfg = "/etc/nixcfg/devices/xeep/default.nix";
  _system = "x86_64-linux";

  system = import "${_nixpkgs}/nixos" {
    system = _system;

    # these two seem to work the same:
    #configuration = _nixoscfg;
    configuration = { imports = [ _nixoscfg ]; };
  };

  #mkMachine1 = c: (nixos { configuration = c; }).system;

  pkgs = import _nixpkgs {
    system = _system;
    inherit (ccc.config.nixpkgs) config overlays;
  };

  ccc = import "${_nixpkgs}/nixos/lib/eval-config.nix" {
    inherit (pkgs) system;
    inherit pkgs;
    modules = [ _nixoscfg ];
  };

  #mkMachine2 = c: (import "${_nixpkgs}/nixos/lib/eval-config.nix" {
  #   system = _system;
  #   pkgs = nixpkgs.pkgs;
  #  inherit (nixpkgs) system;
  #  modules = [ cfg ];
  #}).config.system.build.toplevel;

  #pkgs = import nixpkgs {};
  #patches = import ./xeep/patches.nix { inherit pkgs; };
  #result = {
  #  xeep = (mkMachine2 ./xeep/default.nix);
  #};
in
  ccc.config.system.build.toplevel
  #system.config.system.build.toplevel
  #cfg.config.system.build.toplevel

