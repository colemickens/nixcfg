{
  description = "colemickens-nixcfg";

  # TODO: revisit/checkout: mic92/envfs, nickel, wfvm
  # TODO: promote nix-rice (rename to nix-iterm-themes) to nix-community
  # TODO: nix-rice is active?? do we want to collab? appearance module as a full idea?


  # TODO: adopt lanzaboote / bootis / bootspec
  # TODO: remove other SBC crap
  # TODO: add firmware build for the Glove80 keyboard

  inputs = {
    lib-aggregate = { url = "github:nix-community/lib-aggregate"; }; #TODO: boo name! "libaggregate"?

    nixpkgs-stable = { url = "github:nixos/nixpkgs/nixos-22.11"; }; # any stable to use

    cmpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; };
    cmpkgs-cross-riscv64 = { url = "github:colemickens/nixpkgs/cmpkgs-cross-riscv64"; };
    cmpkgs-rpipkgs = { url = "github:colemickens/nixpkgs/cmpkgs-rpipkgs"; }; # used only for tow-boot/rpi

    # core system/inputs
    firefox-nightly = { url = "github:colemickens/flake-firefox-nightly"; inputs."nixpkgs".follows = "cmpkgs"; };
    home-manager = { url = "github:colemickens/home-manager/cmhm"; inputs."nixpkgs".follows = "cmpkgs"; };
    nixos-hardware = { url = "github:nixos/nixos-hardware"; };
    nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland/master"; inputs."nixpkgs".follows = "cmpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix/master"; inputs."nixpkgs".follows = "cmpkgs"; };
    # TODO: add lanzaboot
    # TODO: add bootis

    # SBC-adjacent inputs
    visionfive-nix = { url = "github:colemickens/visionfive-nix"; inputs."nixpkgs".follows = "cmpkgs-cross-riscv64"; };
    nixos-riscv64 = { url = "github:colemickens/nixos-riscv64"; inputs."nixpkgs".follows = "cmpkgs-cross-riscv64"; };

    # devtools:
    terranix = { url = "github:terranix/terranix"; inputs."nixpkgs".follows = "cmpkgs"; }; # packet/terraform deployments
    fenix = { url = "github:nix-community/fenix"; inputs."nixpkgs".follows = "cmpkgs"; }; # used for nightly rust devtools
    helix = { url = "github:helix-editor/helix"; };
    jj = { url = "github:martinvonz/jj"; };
    nix-eval-jobs = { url = "github:nix-community/nix-eval-jobs"; };
    nix-update = { url = "github:Mic92/nix-update"; };

    # experimental/unused:
    nix-netboot-server = { url = "github:DeterminateSystems/nix-netboot-serve"; };
    nix-rice = { url = "github:colemickens/nix-rice"; inputs."nixpkgs".follows = "cmpkgs"; };
  };

  # TODO: re-investigate nixConfig, maybe it will be less soul-crushing one day

  ## OUTPUTS ##################################################################
  outputs = inputs:
    let
      lib = inputs.lib-aggregate.lib;

      mkSystem = n: v: (v.pkgs.lib.nixosSystem {
        modules = [
          ./hosts/${n}/configuration.nix
          # ({ config, lib, ... }: {
          #   config.nixpkgs.buildPlatform.system =
          #     lib.mkIf (builtins.hasAttr "buildSys" v) v.buildSys; })
        ];
        specialArgs = { inherit inputs; };
      });

      ## NIXOS CONFIGS + TOPLEVELS ############################################
      nixosConfigs = {
        # misc
        installer = { pkgs = inputs.cmpkgs; };

        # actual machines:
        raisin = { pkgs = inputs.cmpkgs; };
        slynux = { pkgs = inputs.cmpkgs; };
        xeep = { pkgs = inputs.cmpkgs; };
        zeph = { pkgs = inputs.cmpkgs; };
      };

      nixosConfigurations = (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigs);
      toplevels = (lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations);

      ## SPECIAL OUTPUTS ######################################################
      images = let cfg = n: nixosConfigurations."${n}".config; in {
        installer = (cfg "installer").system.build.isoImage;
        glove80firmware = {};
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
        inherit images nixosModules overlays;
      })
      (
        ## SYSTEM-SPECIFIC OUTPUTS ############################################
        lib.flake-utils.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
          let
            importPkgs = npkgs: extraCfg: (import npkgs {
              inherit system;
              overlays = [ overlays.default ];
              config = ({ allowAliases = false; } // extraCfg);
            });
            pkgs = importPkgs inputs.cmpkgs { };
            pkgsStable = importPkgs inputs.nixpkgs-stable { };
            pkgsUnfree = importPkgs inputs.cmpkgs { allowUnfree = true; };
            mkShell = (name: import ./shells/${name}.nix { inherit inputs pkgs; });
            mkAppScript = (name: script: {
              type = "app";
              program = (pkgsStable.writeScript "${name}.sh" script).outPath;
            });
          in
          rec {
            inherit pkgs;
            inherit pkgsStable;
            inherit pkgsUnfree;

            ## DEVSHELLS # some of 'em kinda compose ##########################
            devShells = (lib.flip lib.genAttrs mkShell [
              "ci"
              "devenv"
              "devtools"
              "uutils"
            ]) // { default = devShells.ci; };

            ## APPS ###########################################################
            apps = lib.recursiveUpdate { }
              (
                let tfout = import ./cloud { inherit (inputs) terranix; inherit pkgs; }; in {
                  tf = { type = "app"; program = tfout.tf.outPath; };
                  tf-apply = { type = "app"; program = tfout.apply.outPath; };
                  tf-destroy = { type = "app"; program = tfout.destroy.outPath; };
                }
              );

            ## PACKAGES #######################################################
            packages = (pkgs.__colemickens_nixcfg_pkgs);

            ## CI #############################################################
            ciBundles = {
              default = lib.flake-utils.flattenTree
                (lib.mapAttrs (n: v: v // { recurseForDerivations = true; }) ciAttrs);
            };
            ciAttrs = {
              shells = (lib.genAttrs [ "devtools" "ci" "devenv" ]
                (n: inputs.self.devShells.${system}.${n}.inputDerivation));
              packages = (inputs.self.packages.${system});
              # TODO: this probably evals ALL hosts... sadge
              toplevels = builtins.filter (x: x.system == system) (builtins.attrValues toplevels);
            };
          })
      )
  ;
}
