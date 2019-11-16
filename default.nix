let
  mkSystem = (import ./lib.nix {}).mkSystem;
in rec {
  # xeep with local nixpkgs
  xeep-sway = (mkSystem rec {
    nixpkgs = ../nixpkgs; extraModules = [ ./machines/xeep/sway.nix ];
  }).config.system.build.toplevel;
  xeep-gnome = (mkSystem rec {
    nixpkgs = ../nixpkgs; extraModules = [ ./machines/xeep/gnome.nix ];
  }).config.system.build.toplevel;
  xeep-plasma = (mkSystem rec {
    nixpkgs = ../nixpkgs; extraModules = [ ./machines/xeep/plasma.nix ];
  }).config.system.build.toplevel;

  # for continous integration
  xeep-sway__cmpkgs = (mkSystem rec {
    nixpkgs = (import ./nixpkgs/cmpkgs);
    extraModules = [ ./machines/xeep/sway.nix ];
  }).config.system.build.toplevel;
  xeep-sway__nixos-unstable = (mkSystem rec {
    nixpkgs = (import ./nixpkgs/nixos-unstable);
    extraModules = [ ./machines/xeep/sway.nix ];
  }).config.system.build.toplevel;
  xeep-sway__nixos-unstable-small = (mkSystem rec {
    nixpkgs = (import ./nixpkgs/nixos-unstable-small);
    extraModules = [ ./machines/xeep/sway.nix ];
  }).config.system.build.toplevel;

  xeep-ci = [
    xeep-sway__cmpkgs
    xeep-sway__nixos-unstable
    xeep-sway__nixos-unstable-small
  ];
}
