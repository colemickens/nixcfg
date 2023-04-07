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

    firefox-nightly = { url = "github:colemickens/flake-firefox-nightly"; inputs."nixpkgs".follows = "cmpkgs"; };
    home-manager = { url = "github:colemickens/home-manager/cmhm"; inputs."nixpkgs".follows = "cmpkgs"; };
    nixos-hardware = { url = "github:nixos/nixos-hardware"; };
    nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland/master"; inputs."nixpkgs".follows = "cmpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix/master"; inputs."nixpkgs".follows = "cmpkgs"; };
    hyprland = { url = "github:hyprwm/Hyprland"; inputs."nixpkgs".follows = "cmpkgs"; };
    # hyprland = { url = "github:hyprwm/Hyprland"; inputs."nixpkgs".follows = "cmpkgs"; };
    ironbar = { url = "github:JakeStanger/ironbar"; inputs."nixpkgs".follows = "cmpkgs"; };
    cosmic = { url = "github:pop-os/cosmic-comp"; inputs = { "fenix".follows = "fenix"; "nixpkgs".follows = "cmpkgs"; }; };

    nix-rice = { url = "github:colemickens/nix-rice"; inputs."nixpkgs".follows = "cmpkgs"; };
    terranix = { url = "github:terranix/terranix"; inputs."nixpkgs".follows = "cmpkgs"; };
    fenix = { url = "github:figsoda/fenix"; inputs."nixpkgs".follows = "cmpkgs"; }; # used for nightly rust devtools

    visionfive-nix = { url = "github:colemickens/visionfive-nix"; inputs."nixpkgs".follows = "cmpkgs-cross-riscv64"; };
    nixos-riscv64 = { url = "github:colemickens/nixos-riscv64"; inputs."nixpkgs".follows = "cmpkgs-cross-riscv64"; };

    # devtools:
    helix = { url = "github:helix-editor/helix"; inputs."nixpkgs".follows = "cmpkgs"; };
    jj = { url = "github:martinvonz/jj"; inputs."nixpkgs".follows = "cmpkgs"; };
    nix-eval-jobs = { url = "github:nix-community/nix-eval-jobs"; inputs."nixpkgs".follows = "cmpkgs"; };
    # experimental:
    nix-netboot-server = { url = "github:DeterminateSystems/nix-netboot-serve"; };
    nix-update = { url = "github:colemickens/nix-update"; };
    # nix-update = { url = "github:Mic92/nix-update"; };

    # random apps:
    jstest-gtk = { url = "gitlab:jstest-gtk/jstest-gtk"; inputs."nixpkgs".follows = "cmpkgs"; };
    xboxdrv = { url = "gitlab:xboxdrv/xboxdrv"; /*inputs."nixpkgs".follows = "cmpkgs";*/ };

    # <maybe-unused>
    # impermanence = { url = "github:nix-community/impermanence"; }; # TODO: use it or lose it
    # nickel = { url = "github:tweag/nickel"; };
    # rust-overlay = { url = ""; };
    # </maybe-unused>

    # <tow-boot>
    tow-boot-rpi = {
      url = "github:colemickens/Tow-Boot/rpi";
      inputs."nixpkgs".follows = "cmpkgs";
      inputs.rpipkgs.follows = "cmpkgs-rpipkgs";
    };
    tow-boot-radxa-zero = {
      url = "github:colemickens/Tow-Boot/radxa-zero";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    tow-boot-radxa-rock5b = {
      url = "github:colemickens/Tow-Boot/radxa-rock5b";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    tow-boot-visionfive = {
      url = "github:colemickens/Tow-Boot/visionfive";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    # </tow-boot>

    # <mobile-nixos>
    mobile-nixos-sdm845 = {
      url = "github:colemickens/mobile-nixos/sdm845-blue";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    mobile-nixos-reset-scripts = {
      url = "github:colemickens/mobile-nixos/reset-scripts";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    mobile-nixos-pinephone = {
      url = "github:colemickens/mobile-nixos/pinephone-emmc";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    mobile-nixos-openstick = {
      url = "github:colemickens/mobile-nixos/openstick";
      inputs."nixpkgs".follows = "cmpkgs";
    };
    # </mobile-nixos>
  };

  nixConfig = {
    extra-substituters = [
      "https://cache.nixos.org"
      "https://colemickens.cachix.org"
      "https://nixpkgs-wayland.cachix.org"
      "https://unmatched.cachix.org"
      "https://nix-community.cachix.org"
    ];
    extra-trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4="
      "nixpkgs-wayland.cachix.org-1:3lwxaILxMRkVhehr5StQprHdEo4IrE8sRho9R9HOLYA="
      "unmatched.cachix.org-1:F8TWIP/hA2808FDABsayBCFjrmrz296+5CQaysosTTc="
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    ];
    experimental-features = [ "nix-command" "flakes" "recursive-nix" ];
  };

  ## OUTPUTS ##################################################################
  outputs = inputs:
    let
      lib = inputs.lib-aggregate.lib;

      mkSystem = n: v: (v.pkgs.lib.nixosSystem ({
        # system = v.sys;
        modules = [
          ./hosts/${n}/configuration.nix
        ] ++ (if builtins.hasAttr "buildSys" v then [
          ({ config, ... }: { config.nixpkgs.buildPlatform.system = v.buildSys; })
        ] else [ ]);
        specialArgs = { inherit inputs; };
      }));

      ## NIXOS CONFIGS + TOPLEVELS ############################################
      nixosConfigsEx = {
        misc = {
          installer = { pkgs = inputs.cmpkgs; };
        };
        # phone = {
        #   pinephone = { pkgs = inputs.cmpkgs; };
        #   blueline = { pkgs = inputs.cmpkgs; };
        # };
        # sbc = {
        #   radxazero1 = { pkgs = inputs.cmpkgs; };
        #   rockfiveb1 = { pkgs = inputs.cmpkgs; };
        #   openstick = { pkgs = inputs.cmpkgs; buildSys = "x86_64-linux"; };
        #   aitchninesix1 = { pkgs = inputs.cmpkgs; };
        #   rpifour1 = { pkgs = inputs.cmpkgs-rpipkgs; };
        #   rpithreebp1 = { pkgs = inputs.cmpkgs-rpipkgs; };
        #   rpizerotwo1 = { pkgs = inputs.cmpkgs-rpipkgs; };
        #   visionfiveone1 = { pkgs = inputs.cmpkgs-cross-riscv64; };
        #   visionfivetwo1 = { pkgs = inputs.cmpkgs-cross-riscv64; };
        # };
        pc = {
          # carbon = { pkgs = inputs.cmpkgs; };
          # jeffhyper = { pkgs = inputs.cmpkgs; };
          raisin = { pkgs = inputs.cmpkgs; };
          # slynux = { pkgs = inputs.cmpkgs; };
          xeep = { pkgs = inputs.cmpkgs; };
          zeph = { pkgs = inputs.cmpkgs; };
        };
      };

      nixosConfigs = (lib.foldl' (op: nul: nul // op) { } (lib.attrValues nixosConfigsEx));
      nixosConfigsCi = {
        # TODO: can we shallow eval nixos configs to get hostPlatform and avoid this?
        x86_64-linux = {
          inherit (nixosConfigs)
            zeph xeep raisin
            # jeffhyper slynux carbon
            # openstick
            ;
        };
        aarch64-linux = {
          inherit (nixosConfigs)
            # rpizerotwo1 rpithreebp1 rpifour1
            # radxazero1 rockfiveb1
            # pinephone/*blueline*/
            ;
        };
      };
      deployConfigs = {
        # TODO: replace this with a service that pulls latest built
        # dashboard to show what generation is deployed
        inherit (nixosConfigs)
          zeph
          jeffhyper
          raisin
          slynux
          xeep
          ;
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

      ## OVERLAY ################################################################
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
              wezterm = prev.darwin.apple_sdk_11_0.callPackage ./pkgs/wezterm {
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
        ## SYSTEM-SPECIFIC OUTPUTS ##############################################
        lib.flake-utils.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
          let
            pkgcfg = extraCfg: {
              inherit system;
              overlays = [ overlays.default ];
              config = ({ allowAliases = false; } // extraCfg);
            };
            pkgs_ = np: extraCfg: (import np (pkgcfg extraCfg));
            pkgsFree = pkgs_ inputs.cmpkgs { };
            pkgsUnfree = pkgs_ inputs.cmpkgs { allowUnfree = true; };
            pkgsStable = pkgs_ inputs.nixpkgs-stable { };
            pkgs = pkgsFree;
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
              // { default = devShells.devtools; };

            ## APPS ##############################################################
            apps = lib.recursiveUpdate {}
              (
                let tfout = import ./cloud { inherit (inputs) terranix; inherit pkgs; }; in {
                  tf = { type = "app"; program = tfout.tf.outPath; };
                  tf-apply = { type = "app"; program = tfout.apply.outPath; };
                  tf-destroy = { type = "app"; program = tfout.destroy.outPath; };
                }
              );

            ## PACKAGES ##########################################################
            packages = (pkgsUnfree.__colemickens_nixcfg_pkgs);

            ## NETBOOTS (paused: add grub => nix-netboot-server) #################
            # netboots_ = lib.genAttrs
            #   [ "rpifour1" ]
            #   # [ "x_risky" "rpifour1" "rpithreebp1" "rpizerotwo1" ]
            #   (h: nixosConfigurations.${h}.config.system.build.extras.nfsboot);

            ## CI JOBS ###########################################################
            ciBundles = builtins.mapAttrs (n: v: pkgs.buildEnv { name = "cibundle"; paths = (builtins.attrValues v); }) ciJobs;
            ciJobs = {
              default = { }
                # // (lib.genAttrs [ "devtools" "ci" "devenv" ] (name: inputs.self.devShells.${system}.${name}.inputDerivation))
                # // (lib.genAttrs [ "devtools" "ci" "devenv" ] (name: inputs.self.devShells.${system}.${name}))
                // (inputs.self.packages.${system})
                // (lib.genAttrs (builtins.attrNames nixosConfigsCi.${system}) (n: toplevels."${n}")
              );
            };
          })
      )
  ;
}
