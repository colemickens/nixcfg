{
  description = "A highly structured configuration database.";

  # flakes feedback
  # - i wish inputs were optional so that I could do my current logic
  # - i hate the git url syntax badly

  # somewhat surprised at ppls configs and how they import pkgs and config

  # cached failure isn't actually showing me the ... error?
  # how to use local paths when I want to?

  # credits: bqv, balsoft
  inputs = {
    master = { url = "github:nixos/nixpkgs/master"; };
    unstable = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    small = { url = "github:nixos/nixpkgs/nixos-unstable-small"; };
    cmpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; };

    nix.url = "github:nixos/nix/flakes";
    nix.inputs.nixpkgs.follows = "master";

    home.url = "github:colemickens/home-manager/cmhm";
    home.inputs.nixpkgs.follows = "small"; # TODO: text ref??

    construct.url = "github:matrix-construct/construct";
    construct.inputs.nixpkgs.follows = "cmpkgs";

    hardware = { url = "github:nixos/nixos-hardware";        flake = false; };
    mozilla  = { url = "github:mozilla/nixpkgs-mozilla";     flake = false; };
    wayland  = { url = "github:colemickens/nixpkgs-wayland"; flake=false; };
  };
  
  outputs = inputs@{ self, unstable, small, cmpkgs, home, wayland, ... }:
    let
      pkgImport = pkgs: system:
        import pkgs {
          system = system;
          overlays = cmpkgs.lib.attrValues self.overlays;
          config = { allowUnfree = true; };
        };

      cmpkgs_ = pkgImport cmpkgs "x86_64-linux";
    in rec {
      defaultPackage.x86_64-linux =
        nixosConfigurations.xeep.config.system.build;

      nixosConfigurations = {
        xeep = cmpkgs.lib.nixosSystem {
          system = "x86_64-linux"; # TODO dedupe with above
          modules = [
            (import ./machines/xeep/configuration.nix)
          ];
          specialArgs = { inherit inputs; isFlakes = true; };
        };
      };
    };
}
