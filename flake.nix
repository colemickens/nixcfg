{
  # TODO: revisit/checkout: mic92/envfs, nickel, wfvm

  description = "colemickens - nixos configs, custom packges, misc";

  inputs = {
    flake-utils = { url = "github:numtide/flake-utils"; };
    lib-aggregate = { url = "github:nix-community/lib-aggregate"; }; #TODO: boo name! "libaggregate"?

    nixpkgs-stable = { url = "github:nixos/nixpkgs/nixos-23.05"; }; # any stable to use
    cmpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; };

    mobile-nixos-openstick = {
      url = "github:colemickens/mobile-nixos/openstick";
      inputs."nixpkgs".follows = "cmpkgs";
    };

    # core system/inputs
    firefox-nightly = { url = "github:nix-community/flake-firefox-nightly"; inputs."nixpkgs".follows = "cmpkgs"; };
    home-manager = { url = "github:colemickens/home-manager/cmhm"; inputs."nixpkgs".follows = "cmpkgs"; };
    nixos-hardware = { url = "github:NixOS/nixos-hardware"; };
    nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland/master"; inputs."nixpkgs".follows = "cmpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix/master"; inputs."nixpkgs".follows = "cmpkgs"; };
    lanzaboote = { url = "github:nix-community/lanzaboote"; };

    # devtools:
    crate2nix = { url = "github:kolloch/crate2nix"; flake = false; };
    terranix = { url = "github:terranix/terranix"; inputs."nixpkgs".follows = "cmpkgs"; }; # packet/terraform deployments
    fenix = { url = "github:nix-community/fenix"; inputs."nixpkgs".follows = "cmpkgs"; }; # used for nightly rust devtools
    helix = { url = "github:helix-editor/helix"; };
    jj = { url = "github:martinvonz/jj"; inputs."flake-utils".follows = "flake-utils"; };
    nix-eval-jobs = { url = "github:nix-community/nix-eval-jobs"; };
    nix-update = { url = "github:Mic92/nix-update"; };
    nix-fast-build = { url = "github:Mic92/nix-fast-build"; };

    # zellij
    zellij = { url = "github:a-kenji/zellij-nix"; inputs."flake-utils".follows = "flake-utils"; };
    zjstatus = { url = "github:dj95/zjstatus"; inputs."nixpkgs".follows = "cmpkgs"; };

    # experimental/unused:
    nix-rice = { url = "github:colemickens/nix-rice"; inputs."nixpkgs".follows = "cmpkgs"; };
  };

  # TODO: re-investigate nixConfig, maybe it will be less soul-crushing one day

  ## OUTPUTS ##################################################################
  outputs = inputs:
    let
      defaultSystems = [
        "x86_64-linux"
        # "aarch64-linux"
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
          slynux = { pkgs = inputs.cmpkgs; };
          zeph = { pkgs = inputs.cmpkgs; };

          openstick = {
            pkgs = inputs.cmpkgs;
            path = ./hosts/openstick/cross.nix;
            buildSys = "x86_64-linux";
          };
        };
        "aarch64-linux" = { };
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
            ## FORMATTER ######################################################
            formatter = pkgs.${system}.nixpkgs-fmt;
            # formatter = pkgs.${system}.nixfmt;
            # formatter = pkgs.${system}.alejandra;

            ## DEVSHELLS # some of 'em kinda compose ##########################
            devShells = (lib.flip lib.genAttrs mkShell [
              "ci"
              "dev"
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
                let
                  pkgs_ = pkgs.${system};
                  tfout = import ./cloud { inherit (inputs) terranix; pkgs = pkgs_; };
                  installer = nixosConfigurations.installer.config.system.build;
                  installerIsoName = installer.isoImage.isoName;
                  installerIso = "${installer.isoImage}/iso/${installer.isoImage.isoName}";
                  nfb = inputs.nix-fast-build.outputs.packages.${system}.default;
                in
                {
                  tf = { type = "app"; program = tfout.tf.outPath; };
                  tf-apply = { type = "app"; program = tfout.apply.outPath; };
                  tf-destroy = { type = "app"; program = tfout.destroy.outPath; };

                  test-installer = {
                    type = "app";
                    program = (pkgs_.writeShellScript "test-vm" ''
                      ${pkgs_.qemu}/bin/qemu-img create -f qcow2 /tmp/installer-vm-vdisk1 10G
                      ${pkgs_.qemu}/bin/qemu-system-x86_64 -enable-kvm -nographic -m 2048 -boot d \
                        -cdrom "${installerIso}" -hda /tmp/installer-vm-vdisk1 \
                        -net user,hostfwd=tcp::10022-:22 -net nic
                    '').outPath;
                  };
                  cacheme = {
                    type = "app";
                    program = (pkgs_.writeShellScript "build-cache-me" ''
                      ${nfb}/bin/nix-fast-build --flake '${inputs.self}#ciAttrs'
                      ls 'result*' | cachix push colemickens
                    '').outPath;
                  };
                }
              );

            ## PACKAGES #######################################################
            packages = (pkgs.${system}.__colemickens_nixcfg_pkgs);
            legacyPackages = pkgs;

            ## CI #############################################################
            # TODO: move these to checks? implement checks?
            # how to use these with nix-fast-build etc?
            ciAttrs = {
              shells = lib.genAttrs
                (builtins.attrNames devShells)
                (n: inputs.self.devShells.${system}.${n}.inputDerivation);
              packages = (inputs.self.packages.${system});
              extra = (inputs.self.extra.${system});
              toplevels = lib.genAttrs
                (builtins.attrNames nixosConfigsEx.${system})
                (n: toplevels.${n});
            };

            ## CHECKS ########################################################
            checks =
              let
                extra = lib.mapAttrs' (n: lib.nameValuePair "extra-${n}") inputs.self.extra;
                packages = lib.mapAttrs' (n: lib.nameValuePair "package-${n}") inputs.self.packages;
                devShells = lib.mapAttrs' (n: lib.nameValuePair "devShell-${n}") inputs.self.devShells;
                toplevels = lib.mapAttrs' (n: lib.nameValuePair "toplevels-${n}") inputs.self.toplevels;
              in
              extra // packages // devShells // toplevels;
          })
      );
}
