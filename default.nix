let
  mkSystem = (import ./lib.nix { }).mkSystem;
  raspberry_ = (mkSystem rec {
    nixpkgs = ../nixpkgs;
    extraModules = [ ./machines/raspberry/default.nix ];
    system = "aarch64-linux";
  }).config.system.build;
in rec {
  # TODO:
  # continue removing these into their machine dirs?

  #
  ### LAPTOP CONFIG
  xeep-sway = (mkSystem rec {
    nixpkgs = ../nixpkgs;
    extraModules = [ ./machines/xeep/sway.nix ];
  }).config.system.build.toplevel;

  #
  ### DESKTOP CONFIG
  slynux = (mkSystem rec {
    nixpkgs = ../nixpkgs;
    extraModules = [ ./machines/slynux/sway.nix ];
  }).config.system.build.toplevel;

  #
  ### GCP VM
  #gcpdrivebridge = (mkSystem rec {
  #  nixpkgs = ../nixpkgs;
  #  extraModules = [ ./machines/gcpdrivebridge/image.nix ];
  #}).config.system.build.googleComputeImage;

  #
  ### RPi4 Configurations
  raspberry_ = (mkSystem rec {
    nixpkgs = ../nixpkgs;
    extraModules = [ ./machines/raspberry/default.nix ];
    system = "aarch64-linux";
  }).config.system.build;

  raspberry = raspberry_.toplevel;
  #raspberry_image = raspberry_.sdImage;

  #
  ### Dad Experimental HA Hyper-V VM
  jeffhyper = (mkSystem rec {
    nixpkgs = ../nixpkgs;
    extraModules = [ ./machines/jeffhyper/configuration.nix ];
    system = "x86_64-linux";
  }).config.system.build.toplevel;

  #
  ### RPi4 EXPERIMENTAL!
  # this is the payload
  rpikexec = (mkSystem rec {
    nixpkgs = ../nixpkgs;
    extraModules = [ ./machines/rpikexec/default.nix ];
    system = "aarch64-linux";
  }).config.system.build.fullball;
  # this is the initial boot sd card image
  rpiboot = (mkSystem rec {
    nixpkgs = ../nixpkgs;
    extraModules = [ ./machines/rpiboot/default.nix ];
    system = "aarch64-linux";
  }).config.system.build.sdImage;
}
