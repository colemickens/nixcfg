let mkSystem = (import ./lib.nix { }).mkSystem;
in rec {
  # xeep with local nixpkgs
  xeep-sway = (mkSystem rec {
    nixpkgs = ../nixpkgs;
    extraModules = [ ./machines/xeep/sway.nix ];
  }).config.system.build.toplevel;

  #gcpdrivebridge = (mkSystem rec {
  #  nixpkgs = ../nixpkgs;
  #  extraModules = [ ./machines/gcpdrivebridge/image.nix ];
  #}).config.system.build.googleComputeImage;

  #azplex = (mkSystem rec {
  #  nixpkgs = ../nixpkgs;
  #  extraModules = [ ./machines/azure/image-azplex.nix ];
  #}).config.system.build.azureImage;

  #azbuildworld = (mkSystem rec {
  #  nixpkgs = ../nixpkgs;
  #  extraModules = [ ./machines/azure/image-azbuildworld.nix ];
  #}).config.system.build.azureImage;

  raspberry_ = (mkSystem rec {
    nixpkgs = ../nixpkgs-rpi;
    extraModules = [ ./machines/raspberry/default.nix ];
    system = "aarch64-linux";
  }).config.system.build;
  raspberry = raspberry_.toplevel;
  raspberry_image = raspberry_.sdImage;

  rpikexec = (mkSystem rec {
    nixpkgs = ../nixpkgs-rpi;
    extraModules = [ ./machines/rpikexec/default.nix ];
    system = "aarch64-linux";
  }).config.system.build.fullball;

  rpiboot = (mkSystem rec {
    nixpkgs = ../nixpkgs-rpi;
    extraModules = [ ./machines/rpiboot/default.nix ];
    system = "aarch64-linux";
  }).config.system.build.sdImage;
}
