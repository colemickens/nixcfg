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
}
