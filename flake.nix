#WHY:
# networkmanager
# foot
# in _ANY_ of our builds:

{
  description = "colemickens-nixcfg";

  # TODO: revisit/checkout: mic92/envfs, nickel, wfvm
  # TODO: promote nix-rice (rename to nix-iterm-themes) to nix-community
  # TODO: nix-rice is active?? do we want to collab? appearance module as a full idea?


  # TODO: adopt lanzaboote / bootis / bootspec
  # TODO: remove other SBC crap
  # TODO: add firmware build for the Glove80 keyboard

  inputs = {
    systems = { url = "path:./flake.systems.nix"; flake = false; };
    flake-utils = { url = "github:numtide/flake-utils"; inputs."systems".follows = "systems"; };

    lib-aggregate = { url = "github:nix-community/lib-aggregate"; }; #TODO: boo name! "libaggregate"?

    nixpkgs-stable = { url = "github:nixos/nixpkgs/nixos-23.05"; }; # any stable to use

    cmpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; };
    cmpkgs-cross = { url = "github:colemickens/nixpkgs/cmpkgs-cross"; };
    cmpkgs-cross-riscv64 = { url = "github:colemickens/nixpkgs/cmpkgs-cross-riscv64"; };
    cmpkgs-rpipkgs = { url = "github:colemickens/nixpkgs/cmpkgs-rpipkgs"; }; # used only for tow-boot/rpi

    mobile-nixos-openstick = {
      url = "github:colemickens/mobile-nixos/openstick";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    # tow-boot-visionfive = {
    #   url = "github:colemickens/tow-boot/visionfive";
    #   inputs."nixpkgs".follows = "cmpkgs";
    # };
    tow-boot-radxa-rock5b = {
      url = "github:colemickens/tow-boot/radxa-rock5b";
      inputs."nixpkgs".follows = "cmpkgs";
    };

    # core system/inputs
    firefox-nightly = { url = "github:colemickens/flake-firefox-nightly"; inputs."nixpkgs".follows = "cmpkgs"; };
    home-manager = { url = "github:colemickens/home-manager/cmhm"; inputs."nixpkgs".follows = "cmpkgs"; };
    nixos-hardware = { url = "github:colemickens/nixos-hardware"; };
    nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland/master"; inputs."nixpkgs".follows = "cmpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix/master"; inputs."nixpkgs".follows = "cmpkgs"; };
    lanzaboote = { url = "github:nix-community/lanzaboote"; inputs.nixpkgs.follows = "cmpkgs"; };

    # SBC-adjacent inputs
    visionfive-nix = { url = "github:colemickens/visionfive-nix"; inputs."nixpkgs".follows = "cmpkgs-cross-riscv64"; };
    nixos-riscv64 = { url = "github:colemickens/nixos-riscv64"; inputs."nixpkgs".follows = "cmpkgs-cross-riscv64"; };
    # TODO: investigate THEIR nixpkgs........ riscv fork
    nixos-riscv = { url = "github:NickCao/nixos-riscv"; inputs."nixpkgs".follows = "cmpkgs-cross-riscv64"; };

    # devtools:
    terranix = { url = "github:terranix/terranix"; inputs."nixpkgs".follows = "cmpkgs"; }; # packet/terraform deployments
    fenix = { url = "github:nix-community/fenix"; inputs."nixpkgs".follows = "cmpkgs"; }; # used for nightly rust devtools
    helix = { url = "github:helix-editor/helix"; };
    # jj = { url = "github:martinvonz/jj"; inputs."flake-utils".inputs."systems".follows = "systems"; };
    jj = { url = "github:martinvonz/jj"; inputs."flake-utils".follows = "flake-utils"; };
    zellij = { url = "github:a-kenji/zellij-nix/bee0cae93b4cbcd0a1ad1a62e70709b9db0f5c7c"; inputs."flake-utils".follows = "flake-utils"; };
    # TODO: un-pin this eventually...
    # zellij = { url = "github:a-kenji/zellij-nix"; inputs."flake-utils".follows = "flake-utils"; };
    # inputs."nixpkgs".follows = "cmpkgs"; };
    nix-eval-jobs = { url = "github:nix-community/nix-eval-jobs"; };
    # nix-eval-jobs = { url = "github:colemickens/nix-eval-jobs"; };
    nix-update = { url = "github:Mic92/nix-update"; };

    # experimental/unused:
    nix-netboot-server = { url = "github:DeterminateSystems/nix-netboot-serve"; };
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
        config = ({ allowAliases = false; } // extraCfg);
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
          xeep = { pkgs = inputs.cmpkgs; };
          zeph = { pkgs = inputs.cmpkgs; };

          # pktspot1 = { pkgs = inputs.cmpkgs; };

          # used as cross-built bootstrap for getting a builder up, then pivoting to native builds
          # TODO
          openstick-cross = {
            pkgs = inputs.cmpkgs-cross;
            path = ./hosts/openstick/cross.nix;
            buildSys = "x86_64-linux";
          };
          rocky-cross = {
            pkgs = inputs.cmpkgs-cross;
            path = ./hosts/rocky/cross.nix;
            buildSys = "x86_64-linux";
          };
          # rocky-sdcard = {
          #   # TODO FIXME
          #   # TODO: finish, must lay it out
          #   pkgs = inputs.cmpkgs-cross;
          #   path = ./hosts/rocky/sdcard.nix;
          #   buildSys = "x86_64-linux";
          # };
          vf2 = {
            pkgs = inputs.cmpkgs-cross-riscv64;
            path = ./hosts/vf2/cross.nix;
            buildSys = "x86_64-linux";
          };
          # vf2-netboot = {
          #   pkgs = inputs.cmpkgs-cross-riscv64;
          #   path = ./hosts/vf2/netboot.nix;
          #   buildSys = "x86_64-linux";
          # };
          # vf2-sdcard = {
          #   pkgs = inputs.cmpkgs-cross-riscv64;
          #   path = ./hosts/vf2/sdcard.nix;
          #   buildSys = "x86_64-linux";
          # };
          # lipi4a = {
          #   pkgs = inputs.cmpkgs-cross-riscv64;
          #   path = ./hosts/lipi4a/configuration.nix;
          #   buildSys = "x86_64-linux";
          # };
          # lipi4a-sdcard = {
          #   pkgs = inputs.cmpkgs-cross-riscv64;
          #   path = ./hosts/lipi4a/sdcard.nix;
          #   buildSys = "x86_64-linux";
          # };
          h96-cross = {
            pkgs = inputs.cmpkgs-cross;
            path = ./hosts/h96/cross.nix;
            buildSys = "x86_64-linux";
          };
          h96-netboot = {
            pkgs = inputs.cmpkgs-cross;
            path = ./hosts/h96/netboot.nix;
            buildSys = "x86_64-linux";
          };
        };
        "aarch64-linux" = {
          # ocii = {
          #   pkgs = inputs.cmpkgs;
          #   path = ./images/ocii/oci-image.nix;
          # };
          openstick = {
            # PROBLEM!!
            path = ./hosts/openstick/configuration.nix;
            pkgs = inputs.cmpkgs-cross;
          };
          rocky = {
            path = ./hosts/rocky/configuration.nix;
            pkgs = inputs.cmpkgs;
          };
          h96 = {
            pkgs = inputs.cmpkgs-cross;
            path = ./hosts/h96/configuration.nix;
          };
        };
        "riscv64-linux" = {
          vf2-native = {
            path = ./hosts/vf2/configuration.nix;
            pkgs = inputs.cmpkgs-cross-riscv64;
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
          # vf2-firmware = pkgs.x86_64-linux.pkgsCross.riscv64.callPackage
          #   "${inputs.nixos-hardware}/starfive/visionfive/v2/firmware.nix"
          #   { };
          # vf2-sdcard-sdimage = nixosConfigurations.vf2-sdcard.config.system.build.sdImage;
          # lipi4a-sdcard-sdimage = nixosConfigurations.lipi4a-sdcard.config.system.build.sdImage;
          rocky-firmware = nixosConfigurations.rocky.config.system.build.tow-boot.outputs;
          # rocky-sdcard-sdimage = nixosConfigurations.rocky-sdcard.config.system.build.sdImage;
        };
        aarch64-linux = { };
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
              nushell = prev.callPackage ./pkgs/nushell {
                doCheck = false; # TODO consider removing
                inherit (prev.darwin.apple_sdk.frameworks) AppKit Security;
                inherit (prev.darwin.apple_sdk_11_0) Libsystem;
              };
              # git-repo-manager = prev.callPackage ./pkgs/git-repo-manager {
              #   fenix = inputs.fenix;
              # };
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
