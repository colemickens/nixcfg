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

  gcpdrivebridge = (mkSystem rec {
    nixpkgs = ../nixpkgs; extraModules = [ ./machines/gcpdrivebridge/image.nix ];
  }).config.system.build.googleComputeImage;

  azplex = (mkSystem rec {
    nixpkgs = ../nixpkgs; extraModules = [ ./machines/azure/image-azplex.nix ];
  }).config.system.build.azureImage;

  azbuildworld = (mkSystem rec {
    nixpkgs = ../nixpkgs; extraModules = [ ./machines/azure/image-azbuildworld.nix ];
  }).config.system.build.azureImage;

  raspberry_ = (mkSystem rec {
    nixpkgs = ../nixpkgs; extraModules = [ ./machines/raspberry/default.nix ];
    system = "aarch64-linux";
  }).config.system.build;
  raspberry = raspberry_.toplevel;
  raspberry_image = raspberry_.sdImage;
}
