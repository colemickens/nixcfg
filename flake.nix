{
  # TODO: revisit/checkout: mic92/envfs, nickel, wfvm

  description = "colemickens - nixos configs, custom packges, misc";

  inputs = {
    # systems = { url = "git+file:.?path=flake.systems.nix"; flake = false; };
    systems = { url = "path:./flake.systems.nix"; flake = false; };
    flake-utils = { url = "github:numtide/flake-utils"; inputs."systems".follows = "systems"; };
    lib-aggregate = { url = "github:nix-community/lib-aggregate"; }; #TODO: boo name! "libaggregate"?
    
    nixpkgs-stable = { url = "github:nixos/nixpkgs/nixos-23.05"; }; # any stable to use
    cmpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; };

    mobile-nixos-openstick = {
      url = "github:colemickens/mobile-nixos/openstick";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    tow-boot-alirock-h96maxv58 = {
      url = "github:colemickens/tow-boot/alirock-h96maxv58";
      inputs."nixpkgs".follows = "cmpkgs";
    };

    # core system/inputs
    # TODO: undo this!!!!!!
    firefox-nightly = { url = "github:nix-community/flake-firefox-nightly"; inputs."nixpkgs".follows = "cmpkgs"; };
    home-manager = { url = "github:colemickens/home-manager/cmhm"; inputs."nixpkgs".follows = "cmpkgs"; };
    nixos-hardware = { url = "github:colemickens/nixos-hardware"; };
    nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland/master"; inputs."nixpkgs".follows = "cmpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix/master"; inputs."nixpkgs".follows = "cmpkgs"; };
    # lanzaboote = { url = "github:nix-community/lanzaboote"; inputs.nixpkgs.follows = "cmpkgs"; };
    lanzaboote = { url = "github:nix-community/lanzaboote"; };

    # devtools:
    crate2nix = { url = "github:kolloch/crate2nix"; flake = false; };
    terranix = { url = "github:terranix/terranix"; inputs."nixpkgs".follows = "cmpkgs"; }; # packet/terraform deployments
    fenix = { url = "github:nix-community/fenix"; inputs."nixpkgs".follows = "cmpkgs"; }; # used for nightly rust devtools
    helix = { url = "github:helix-editor/helix"; };
    jj = { url = "github:martinvonz/jj"; inputs."flake-utils".follows = "flake-utils"; };
    nix-eval-jobs = { url = "github:nix-community/nix-eval-jobs"; };
    nix-update = { url = "github:Mic92/nix-update"; };
    # zellij = { url = "github:a-kenji/zellij-nix/bee0cae93b4cbcd0a1ad1a62e70709b9db0f5c7c"; inputs."flake-utils".follows = "flake-utils"; };
    zellij = { url = "github:a-kenji/zellij-nix"; inputs."flake-utils".follows = "flake-utils"; };

    # experimental/unused:
    nix-rice = { url = "github:colemickens/nix-rice"; inputs."nixpkgs".follows = "cmpkgs"; };
  };

  # TODO: re-investigate nixConfig, maybe it will be less soul-crushing one day

  ## OUTPUTS ##################################################################
  outputs = inputs:
    let
      defaultSystems = [
        "x86_64-linux"
        "aarch64-linux"
        # "riscv64-linux"
      ];

      lib = inputs.lib-aggregate.lib;

      importPkgs = npkgs: extraCfg: (lib.genAttrs defaultSystems (system: import npkgs {
        inherit system;
        overlays = [ overlays.default ];
        # config = let cfg = ({ allowAliases = false; } // extraCfg); in (builtins.trace cfg cfg);
        config = let cfg = ({ allowAliases = false; } // extraCfg); in cfg;
      }));
      pkgs = importPkgs inputs.cmpkgs { };
      pkgsStable = importPkgs inputs.nixpkgs-stable { };
      pkgsUnfree = importPkgs inputs.cmpkgs { allowUnfree = true; };

      mkSystem = n: v: (v.pkgs.lib.nixosSystem {
        modules = [
          (v.path or (./hosts/${n}/configuration.nix))
        ] ++ (if (! builtins.hasAttr "buildSys" v) then [ ] else [{
          config.nixpkgs.buildPlatform.system = v.buildSys;
        }]);
        specialArgs = { inherit inputs; };
      });

      ## NIXOS CONFIGS + TOPLEVELS ############################################
      nixosConfigsEx = {
        "x86_64-linux" = rec {
          # misc
          installer = {
            pkgs = inputs.cmpkgs;
            path = ./images/installer/configuration.nix;
          };

          # actual machines:
          raisin = { pkgs = inputs.cmpkgs; };
          zeph = { pkgs = inputs.cmpkgs; };

          # openstick-cross = {
          #   pkgs = inputs.cmpkgs-cross;
          #   path = ./hosts/openstick/cross.nix;
          #   buildSys = "x86_64-linux";
          # };
        };
        "aarch64-linux" = {
          # ocii = {
          #   pkgs = inputs.cmpkgs;
          #   path = ./images/ocii/oci-image.nix;
          # };
          openstick = {
            path = ./hosts/openstick/configuration.nix;
            pkgs = inputs.cmpkgs;
          };
          h96maxv58 = {
            pkgs = inputs.cmpkgs;
            path = ./hosts/h96maxv58/configuration.nix;
          };
        };
      };
      nixosConfigs = (lib.foldl' (op: nul: nul // op) { } (lib.attrValues nixosConfigsEx));
      nixosConfigurations = (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigs);
      toplevels = (lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations);

      ## SPECIAL OUTPUTS ######################################################
      extra = {
        # keyed by buildPlatform for usage by ciAttrs
        x86_64-linux = {
          installer = nixosConfigurations.installer.config.system.build.isoImage;
        };
        aarch64-linux = {
          openstick-abootimg = nixosConfigurations.openstick.config.mobile.outputs.android.android-abootimg;
          openstick-bootimg = nixosConfigurations.openstick.config.mobile.outputs.android.android-bootimg;
          h96maxv58-uboot = inputs.tow-boot-alirock-h96maxv58.outputs.packages.aarch64-linux.radxa-rock5b.outputs.firmware;
        };
        riscv64-linux = { };
      };

      ## NIXOS_MODULES # TODO: we don't use these? #############################
      nixosModules = {
        loginctl-linger = import ./modules/loginctl-linger.nix;
        ttys = import ./modules/ttys.nix;
        other-arch-vm = import ./modules/other-arch-vm.nix;
      };

      ## OVERLAY ###############################################################
      overlays = {
        default = (final: prev:
          # TODO: must be a better way?
          let
            __colemickens_nixcfg_pkgs = rec {
              alacritty = prev.callPackage ./pkgs/alacritty {
                inherit (prev.darwin.apple_sdk.frameworks)
                  AppKit CoreGraphics CoreServices CoreText
                  Foundation OpenGL;
              };
              nushell = prev.callPackage ./pkgs/nushell {
                doCheck = false; # TODO consider removing
                inherit (prev.darwin.apple_sdk.frameworks) AppKit Security;
                inherit (prev.darwin.apple_sdk_11_0) Libsystem;
              };
              git-repo-manager = prev.callPackage ./pkgs/git-repo-manager {
                fenix = inputs.fenix;
              };
              rio = prev.callPackage ./pkgs/rio {
                withX11 = false;
              };
              wezterm = prev.darwin.apple_sdk_11_0.callPackage ./pkgs/wezterm {
                doCheck = false; # TODO consider removing
                inherit (prev.darwin.apple_sdk_11_0.frameworks)
                  Cocoa CoreGraphics Foundation UserNotifications;
              };
            };
          in
          __colemickens_nixcfg_pkgs // { inherit __colemickens_nixcfg_pkgs; });
      };
    in
    lib.recursiveUpdate
      ({
        inherit nixosConfigs nixosConfigurations toplevels;
        inherit nixosModules overlays;
        inherit extra;
        inherit pkgs pkgsUnfree;
        ## HM ENVS #####################################################
      })
      (
        ## SYSTEM-SPECIFIC OUTPUTS ############################################
        lib.flake-utils.eachSystem defaultSystems (system:
          let
            mkShell = (name: import ./shells/${name}.nix { inherit inputs; pkgs = pkgs.${system}; });
            mkAppScript = (name: script: {
              type = "app";
              program = (pkgsStable.${system}.writeScript "${name}.sh" script).outPath;
            });
          in
          rec {
            ## DEVSHELLS # some of 'em kinda compose ##########################
            devShells = (lib.flip lib.genAttrs mkShell [
              "ci"
              "devenv"
              "devtools"
              "uutils"
            ]) // {
              default = devShells.ci;
            };

            ## TODO: coercion is still so silly, I should be able to put
            #        this at `outputs.homeConfigurations.x86_64-linux.env-ci`
            ## HM ENVS ########################################################

            homeConfigurations = (lib.genAttrs [ "env-ci" ]
              (h: inputs.home-manager.lib.homeManagerConfiguration {
                pkgs = pkgs.${system};
                modules = [ ./hm/${h}.nix ];
                extraSpecialArgs = { inherit inputs; };
              })
            );
            tophomes = (lib.mapAttrs (_: v: v.activation-script) homeConfigurations);

            ## APPS ###########################################################
            apps = lib.recursiveUpdate { }
              (
                let tfout = import ./cloud { inherit (inputs) terranix; pkgs = pkgs.${system}; }; in {

                  tf = { type = "app"; program = tfout.tf.outPath; };
                  tf-apply = { type = "app"; program = tfout.apply.outPath; };
                  tf-destroy = { type = "app"; program = tfout.destroy.outPath; };
                }
              );

            ## PACKAGES #######################################################
            packages = (pkgs.${system}.__colemickens_nixcfg_pkgs);
            legacyPackages = pkgs;

            ## CI #############################################################
            ciAttrs = {
              shells = (lib.genAttrs [ "devtools" "ci" "devenv" ]
                (n: inputs.self.devShells.${system}.${n}.inputDerivation));
              packages = (inputs.self.packages.${system});
              extra = (inputs.self.extra.${system});
              toplevels = lib.genAttrs
                (builtins.attrNames nixosConfigsEx.${system})
                (n: toplevels.${n});
            };
          })
      );
}
