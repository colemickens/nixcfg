{
  description = "colemickens - nixos configs, custom packges, misc";

  inputs = {
    lib-aggregate.url = "github:nix-community/lib-aggregate";

    cmpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixpkgs-unstable.url = "github:nixos/nixpkgs?ref=nixpkgs-unstable";

    home-manager.url = "github:nix-community/home-manager?ref=master";
    home-manager.inputs."nixpkgs".follows = "cmpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix/master";
    sops-nix.inputs."nixpkgs".follows = "cmpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";

    ucodenix.url = "github:e-tho/ucodenix";

    nix-darwin.url = "github:nix-darwin/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs-unstable";

    # helix
    helix.url = "github:helix-editor/helix";
    helix.inputs.nixpkgs.follows = "cmpkgs";

    # preservation
    preservation.url = "github:nix-community/preservation";

    # random dev tools:
    ghostty.url = "github:ghostty-org/ghostty";
    ghostty.inputs."nixpkgs".follows = "cmpkgs";

    # more dev tools:
    rust-overlay.url = "github:oxalica/rust-overlay";
    rust-overlay.inputs.nixpkgs.follows = "cmpkgs";

    # wip replacement for nixpkgs->github-runners module
    nixos-github-actions.url = "github:colemickens/nixos-github-actions";
    nixos-github-actions.inputs."nixpkgs".follows = "cmpkgs";

    # for work
    # (stable)
    # determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3.tar.gz";
    determinate.url = "github:DeterminateSystems/determinate";
    # (and ... newer...)
    determinate-main-dnixd.url = "https://install.determinate.systems/determinate-nixd/branch/main/x86_64-linux";
    determinate-main-dnixd.flake = false;
    determinate-main-nixsrc.url = "github:DeterminateSystems/nix-src?ref=main";
    determinate-main.url = "https://flakehub.com/f/DeterminateSystems/determinate/3.tar.gz";
    determinate-main.inputs.nix.follows = "determinate-main-nixsrc";
    determinate-main.inputs.determinate-nixd-x86_64-linux.follows = "determinate-main-dnixd";
  };

  ## OUTPUTS ##################################################################
  outputs =
    inputs:
    let
      defaultSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forAllSystems =
        f:
        inputs.nixpkgs.lib.genAttrs defaultSystems (
          system:
          f {
            inherit system;
            pkgs = import inputs.nixpkgs {
              inherit system;
              overlays = [
                inputs.self.overlays.default
              ];
              config.allowAliases = false;
              config.allowUnfree = true;
            };
          }
        );

      lib = inputs.lib-aggregate.lib;

      importPkgs =
        npkgs: extraCfg:
        (lib.genAttrs defaultSystems (
          system:
          import npkgs {
            inherit system;
            config = ({ allowAliases = false; } // extraCfg);
          }
        ));
      pkgs = importPkgs inputs.cmpkgs { };
      pkgsUnfree = importPkgs inputs.cmpkgs { allowUnfree = true; };

      mkSystem =
        n: _v:
        let
          defaults = {
            pkgs = inputs.cmpkgs;
            path = ./hosts/${n}/configuration.nix;
            extraConfig = [ { } ];
          };
          v = defaults // _v;
        in
        (v.pkgs.lib.nixosSystem {
          modules = [ v.path ] ++ v.extraConfig;
          specialArgs.inputs = inputs;
        });

      ## NIX-DARWN
      darwinConfigurationsEx = {
        "aarch64-darwin" = {
          manzana = inputs.nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            modules = [
              ./darwinConfigs/manzana/configuration.nix
            ];
            specialArgs = { inherit inputs; };
          };
        };
        "aarch64-linux" = {};
        "x86_64-linux" = {};
      };
      darwinConfigurations = (lib.foldl' (op: nul: nul // op) { } (lib.attrValues darwinConfigurationsEx));

      ## NIXOS CONFIGS + TOPLEVELS ############################################
      nixosConfigsEx = {
        "x86_64-linux" = {
          raisin = { };
          slynux = { };
          zeph = { };
        };
        "aarch64-linux" = { };
        "aarch64-darwin" = { };
      };
      nixosConfigs = (lib.foldl' (op: nul: nul // op) { } (lib.attrValues nixosConfigsEx));
      nixosConfigurations = (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigs);
      toplevels = (lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations);

      ## SPECIAL OUTPUTS ######################################################
      extra = {
        x86_64-linux = {
          installer =
            (mkSystem "installer-standard-x86_64" {
              path = ./images/installer/configuration-standard.nix;
            }).config.system.build.toplevel;
        };
        aarch64-linux = {
          installer =
            (mkSystem "installer-standard-aarch64" {
              path = ./images/installer/configuration-standard-aarch64.nix;
            }).config.system.build.toplevel;
        };
        aarch64-darwin = { };
        riscv64-linux = { };
      };

      nixosModules = { };
      overlays = { };
    in
    lib.recursiveUpdate
      ({
        inherit
          darwinConfigurations
          darwinConfigurationsEx
          nixosConfigs
          nixosConfigsEx
          nixosConfigurations
          toplevels
          ;
        inherit nixosModules overlays;
        inherit extra;
        inherit pkgs pkgsUnfree;
      })
      (
        ## SYSTEM-SPECIFIC OUTPUTS ############################################
        lib.flake-utils.eachSystem defaultSystems (
          system:
          let
            mkShell =
              name:
              import ./shells/${name}.nix {
                inherit inputs;
                pkgs = pkgs.${system};
              };
          in
          rec {
            formatter = pkgs.${system}.nixfmt;

            devShells =
              (lib.flip lib.genAttrs mkShell [
                "ci"
                # "devenv"
              ])
              // {
                default = devShells.ci;
              };

            checks = 
                let
                  # c_packages = lib.mapAttrs' (
                  #   n: lib.nameValuePair "package-${n}"
                  # ) inputs.self.legacyPackages.${system};
                  c_devShells = lib.mapAttrs' (
                    n: v: lib.nameValuePair "devShell-${n}" v.inputDerivation
                  ) inputs.self.devShells.${system};
                  c_toplevels = lib.mapAttrs' (
                    n: v: (lib.nameValuePair "toplevel-${n}" v.config.system.build.toplevel)
                  ) (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigsEx.${system});
                  c_darwinConfigs = lib.mapAttrs' (
                    n: v: (lib.nameValuePair "darwinConfig-${n}" v.system)
                  ) darwinConfigurationsEx.${system};
                  # c_extra = lib.mapAttrs' (n: v: lib.nameValuePair "extra-${n}" v) inputs.self.extra.${system};
                in
                (/*c_packages // */ c_devShells // c_toplevels // c_darwinConfigs /*// c_extra*/);
          }
        )
      );
}
