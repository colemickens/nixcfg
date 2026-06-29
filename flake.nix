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

    nixos-hardware-k3.url = "github:liberodark/nixos-hardware?ref=spacemit-k3";

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

    # determinate
    determinate.url = "github:DeterminateSystems/determinate";

    # llm-agents
    llm-agents.url = "github:numtide/llm-agents.nix";
    llm-agents.inputs.nixpkgs.follows = "cmpkgs";
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
        "aarch64-linux" = { };
        "x86_64-linux" = { };
      };
      darwinConfigurations = (
        lib.foldl' (op: nul: nul // op) { } (lib.attrValues darwinConfigurationsEx)
      );

      ## NIXOS CONFIGS + TOPLEVELS ############################################
      nixosConfigsEx = {
        "x86_64-linux" = {
          raisin = { };
          zeph = { };
        };
        "riscv64-linux" = {
          jupitertwo = {
            extraConfig = [ { nixpkgs.buildPlatform.system = "x86_64-linux"; } ];
          };
          installer-riscv64 = {
            path = ./images/installer/configuration-riscv64.nix;
            extraConfig = [ { nixpkgs.buildPlatform.system = "x86_64-linux"; } ];
          };
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
            (mkSystem "installer-x86_64" {
              path = ./images/installer/configuration-x86_64.nix;
            }).config.system.build.toplevel;
        };
        aarch64-linux = {
          installer =
            (mkSystem "installer-aarch64" {
              path = ./images/installer/configuration-aarch64.nix;
            }).config.system.build.toplevel;
        };
        aarch64-darwin = { };
        riscv64-linux = {
          installer = nixosConfigurations.installer-riscv64.config.system.build.toplevel;
          iso-bits = nixosConfigurations.installer-riscv64.config.system.build.isoImage.inputDerivation;
        };
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

            checks =
              let
                # c_packages = lib.mapAttrs' (
                #   n: lib.nameValuePair "package-${n}"
                # ) inputs.self.legacyPackages.${system};
                # c_devShells = lib.mapAttrs' (
                #   n: v: lib.nameValuePair "devShell-${n}" v.inputDerivation
                # ) inputs.self.devShells.${system};
                c_toplevels = lib.mapAttrs' (
                  n: v: (lib.nameValuePair "toplevel-${n}" v.config.system.build.toplevel)
                ) (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigsEx.${system});
                c_darwinConfigs = lib.mapAttrs' (
                  n: v: (lib.nameValuePair "darwinConfig-${n}" v.system)
                ) darwinConfigurationsEx.${system};
                # c_extra = lib.mapAttrs' (n: v: lib.nameValuePair "extra-${n}" v) inputs.self.extra.${system};
              in
              # c_packages // c_devShells //
              (
                c_toplevels // c_darwinConfigs # // c_extra
              );
          }
        )
      );
}
