let
  mkSystem = (import ../../../../lib.nix { }).mkSystem;
in
  (mkSystem rec {
    nixpkgs = /home/cole/code/nixpkgs-azure;
    extraModules = [ ./system.nix ];
  }).config.system.build.azureImage
