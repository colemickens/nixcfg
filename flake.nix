{
  description = "colemickens - nixos configs, custom packges, misc";

  inputs = {
    lib-aggregate.url = "github:nix-community/lib-aggregate";
    nixpkgs-stable.url = "github:nixos/nixpkgs?ref=nixos-25.05";
    cmpkgs.url = "github:colemickens/nixpkgs?ref=cmpkgs";
    home-manager.url = "github:colemickens/home-manager/cmhm";
    home-manager.inputs."nixpkgs".follows = "cmpkgs";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix.url = "github:Mic92/sops-nix/master";
    sops-nix.inputs."nixpkgs".follows = "cmpkgs";
    lanzaboote.url = "github:nix-community/lanzaboote";

    ucodenix.url = "github:e-tho/ucodenix";

    # zellij:
    # zellij.url = "github:zellij-org/zellij?ref=web-client-preview";
    # zellij.flake = false;
    # zellij-nix.url = "github:a-kenji/zellij-nix";
    # zellij-nix.inputs."nixpkgs".follows = "cmpkgs";
    # zellij-nix.inputs."zellij".follows = "zellij";
    zjstatus.url = "github:dj95/zjstatus";
    zjstatus.inputs."nixpkgs".follows = "cmpkgs";

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
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/3.tar.gz";
    # (and ... newer...)
    determinate-main-dnixd.url = "https://install.determinate.systems/determinate-nixd/branch/main/x86_64-linux";
    determinate-main-dnixd.flake = false;
    determinate-main-nixsrc.url = "github:DeterminateSystems/nix-src?ref=main";
    determinate-main.url = "https://flakehub.com/f/DeterminateSystems/determinate/3.tar.gz";
    determinate-main.inputs.nix.follows = "determinate-main-nixsrc";
    determinate-main.inputs.determinate-nixd-x86_64-linux.follows = "determinate-main-dnixd";
  };

  nixConfig = {
    builers-use-substitutes = true;
    build-cores = 0;
    # narinfo-cache-negative-ttl = 0;
    extra-substituters = "https://colemickens.cachix.org https://cache.flakehub.com";
    extra-trusted-public-keys = "colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4= cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM= cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio= cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU= cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU= cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8= cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ= cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o= cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y=";
    always-allow-substitutes = true;
  };

  ## OUTPUTS ##################################################################
  outputs =
    inputs:
    let
      defaultSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];

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
      pkgsStable = importPkgs inputs.nixpkgs-stable { };
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

      ## NIXOS CONFIGS + TOPLEVELS ############################################
      nixosConfigsEx = {
        "x86_64-linux" = {
          ds-ws-colemickens = { };
          raisin = { };
          slynux = { };
          zeph = { };
        };
        "aarch64-linux" = { };
      };
      nixosConfigs = (lib.foldl' (op: nul: nul // op) { } (lib.attrValues nixosConfigsEx));
      nixosConfigurations = (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigs);
      toplevels = (lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations);

      ## SPECIAL OUTPUTS ######################################################
      extra = {
        x86_64-linux = {
          installer-standard =
            (mkSystem "installer-standard-x86_864" {
              path = ./images/installer/configuration-standard.nix;
            }).config.system.build.isoImage;
          installer-standard-aarch64 =
            (mkSystem "installer-standard-aarch64" {
              path = ./images/installer/configuration-standard-aarch64.nix;
              extraConfig = [
                {
                  config.nixpkgs.buildPlatform.system = "x86_64-linux";
                }
              ];
            }).config.system.build.isoImage;
        };
        aarch64-linux = { };
        riscv64-linux = { };
      };

      nixosModules = { };
      overlays = { };
    in
    lib.recursiveUpdate
      ({
        inherit
          nixosConfigs
          nixosConfigsEx
          nixosConfigurations
          toplevels
          ;
        inherit nixosModules overlays;
        inherit extra;
        inherit pkgs pkgsStable pkgsUnfree;
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
            ## FORMATTER #######################################################
            formatter = pkgs.${system}.nixfmt;

            ## DEVSHELLS #######################################################
            devShells =
              (lib.flip lib.genAttrs mkShell [
                "ci"
                "devenv"
                "uutils"
              ])
              // {
                default = devShells.ci;
              };

            ## PKGS ############################################################
            legacyPackages = { };

            ## APPS ############################################################
            apps = lib.recursiveUpdate { } ({ });

            ## CI (sorta) #####################################################
            bundles = {
              default = pkgs.${system}.linkFarmFromDrvs "bundle-nixcfg-default" (
                builtins.attrValues checks.default
              );
              extra = pkgs.${system}.linkFarmFromDrvs "bundle-nixcfg-extra" (builtins.attrValues checks.extra);
            };

            ## CHECKS ##########################################################
            checks = {
              default =
                let
                  c_packages = lib.mapAttrs' (
                    n: lib.nameValuePair "package-${n}"
                  ) inputs.self.legacyPackages.${system};
                  c_devShells = lib.mapAttrs' (
                    n: v: lib.nameValuePair "devShell-${n}" v.inputDerivation
                  ) inputs.self.devShells.${system};
                  c_toplevels = lib.mapAttrs' (
                    n: v: (lib.nameValuePair "toplevel-${n}" v.config.system.build.toplevel)
                  ) (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigsEx.${system});
                in
                { } // c_packages // c_toplevels // c_devShells;
              extra = lib.mapAttrs' (n: v: lib.nameValuePair "extra-${n}" v) inputs.self.extra.${system};
            };
          }
        )
      );
}
