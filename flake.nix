{
  description = "colemickens-nixcfg";

  # TODO: revisit/checkout: mic92/envfs, nickel, wfvm
  # TODO: promote nix-rice (rename to nix-iterm-themes) to nix-community
  # TODO: nix-rice is active?? do we want to collab? appearance module as a full idea?

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

  nixConfig = rec {
    # trusted-substituters = [
    #   "https://cache.nixos.org"
    #   "https://colemickens.cachix.org"
    #   "https://nixpkgs-wayland.cachix.org"
    #   "https://unmatched.cachix.org"
    #   "https://nix-community.cachix.org"
    # ];
    # extra-trusted-public-keys = [
    #   "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
    #   "colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4="
    #   "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
    #   "unmatched.cachix.org-1:F8TWIP/hA2808FDABsayBCFjrmrz296+5CQaysosTTc="
    #   "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    # ];
    # experimental-features = [ "nix-command" "flakes" "recursive-nix" ];
  };

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
      nixosConfigsEx = {
        misc = {
          installer = { pkgs = inputs.cmpkgs; };
        };
        pc = {
          raisin = { pkgs = inputs.cmpkgs; };
          slynux = { pkgs = inputs.cmpkgs; };
          xeep = { pkgs = inputs.cmpkgs; };
          zeph = { pkgs = inputs.cmpkgs; };
        };
      };

      nixosConfigs = (lib.foldl' (op: nul: nul // op) { } (lib.attrValues nixosConfigsEx));
      nixosConfigsCi = {
        # TODO: can we shallow eval nixos configs to get hostPlatform and avoid this?
        x86_64-linux = {
          inherit (nixosConfigs)
            zeph xeep raisin slynux
            ;
        };
        aarch64-linux = {
          inherit (nixosConfigs)
            ;
        };
      };
      deployConfigs = {
        # NOTE: these are keyed off the build hosts, not the target arch
        aarch64-linux = { };
        x86_64-linux = {
          inherit (nixosConfigs)
            # risky
            ;
          inherit (nixosConfigs)
            raisin
            slynux
            xeep
            zeph
            ;
        };
      };
      nixosConfigurations = (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigs);
      toplevels = (lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations);

      # TODO: automatic cross-compiling now made easy with {host,build}Platform
      xnixosConfigurations = (lib.mapAttrs (n: v: (mkSystem n (v // { buildSys = "x86_64-linux"; }))) nixosConfigs);
      xtoplevels = (lib.mapAttrs (_: v: v.config.system.build.toplevel) xnixosConfigurations);

      ## SPECIAL OUTPUTS ######################################################
      images = let cfg = n: nixosConfigurations."${n}".config; in {
        installer = (cfg "installer").system.build.isoImage;
        openstick = let o = (cfg "openstick"); in {
          aboot = o.mobile.outputs.android.android-abootimg;
          boot = o.mobile.outputs.android.android-bootimg;
          # 'fastboot flash -S 100M $rootfs/NIXOS_SYSTEM.img'
          rootfs = o.mobile.outputs.generatedFilesystems.rootfs;
        };
        rockfiveb1 = let o = (cfg "rockfiveb1"); in {
          tbsd = o.system.build.tow-boot.outputs.diskImage;
          installFiles = o.system.build.installFiles;
        };
        aitchninesix1 = let o = (cfg "aitchninesix1"); in {
          tbsd = o.system.build.tow-boot.outputs.diskImage;
          installFiles = o.system.build.installFiles;
        };
        rpizerotwo1 = let o = (cfg "rpizerotwo1"); in {
          tbsd = o.system.build.tow-boot.outputs.diskImage;
          installFiles = o.system.build.installFiles;
        };
        # blueline = let o = (mkSystem "blueline" { sys = "x86_64-linux"; pkgs = inputs."nixpkgs"; }).config; in {
        blueline = let o = (cfg "blueline"); in {
          boot = o.mobile.outputs.android.android-bootimg;
        };
      };

      ## NIXOS_MODULES # TODO: we don't use these? #############################
      nixosModules = {
        loginctl-linger = import ./modules/loginctl-linger.nix;
        ttys = import ./modules/ttys.nix;
        other-arch-vm = import ./modules/other-arch-vm.nix;
        # webrtcsink = import ./modules/webrtcsink.nix;
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
        inherit nixosConfigsEx nixosConfigs nixosConfigurations deployConfigs toplevels;
        inherit xnixosConfigurations xtoplevels;
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

            ## DEVSHELLS # some of 'em kinda compose #############################
            devShells = (lib.genAttrs [ "ci" "devenv" "devtools" "gstreamer" "uutils" ] mkShell)
              // { default = devShells.ci; };

            shells = (lib.genAttrs [ "ci" "devenv" "devtools" "gstreamer" "uutils" ] mkShell)
              // { default = shells.ci; };

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
            ciAttrs = let rc = { recurseForDerivations = true; }; in (rc // {
              shells = rc // (lib.genAttrs [ "devtools" "ci" "devenv" ]
                (n: inputs.self.devShells.${system}.${n}.inputDerivation));
              packages = rc // (inputs.self.packages.${system});
              toplevels = rc // (lib.genAttrs (builtins.attrNames nixosConfigsCi.${system})
                (n: toplevels."${n}"));
            });
            # TODO: flesh out:
            # cyclopsJobs = {
              
            # };
          })
      )
  ;
}
