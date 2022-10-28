{
  description = "colemickens-nixcfg";

  inputs = {
    nixlib.url = "github:nix-community/nixpkgs.lib"; #TODO: boo name! "libaggregate"?

    # <cmpkgs> # aka, my package sets
    nixpkgs.url = "github:colemickens/nixpkgs/cmpkgs"; # for my regular nixpkgs
    cross-armv6l.url = "github:colemickens/nixpkgs/cmpkgs-cross-armv6l";
    cross-riscv64.url = "github:colemickens/nixpkgs/cmpkgs-cross-riscv64";
    rpipkgs = { url = "github:colemickens/nixpkgs/cmpkgs-rpipkgs"; };
    # </cmpkgs>

    nix-netboot-server.url = "github:DeterminateSystems/nix-netboot-serve";

    # nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # nixos-stable.url = "github:nixos/nixpkgs/nixos-22.05"; # for cachix
    # riscv64 = { url = "github:zhaofengli/nixos-riscv64"; };
    visionfive-nix.url = "github:colemickens/visionfive-nix";
    visionfive-nix.inputs.nixpkgs.follows = "cross-riscv64";

    home-manager.url = "github:colemickens/home-manager/cmhm";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix/master";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # eep, TODO: do we want to override nixpkgs?
    helix.url = "github:helix-editor/helix";
    jj.url = "github:martinvonz/jj";
    zellij.url = "github:zellij-org/zellij";
    marksman = {
      url = "github:the-mikedavis/marksman/flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # nixos-riscv64.url = "https://github.com/colemickens/nixos-riscv64";
    # jh7100.url = "https://github.com/colemickens/jh7100";

    hardware.url = "github:nixos/nixos-hardware";

    nix-rice.url = "github:colemickens/nix-rice";
    nix-rice.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland/master";
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";

    firefox.url = "github:colemickens/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence";

    tow-boot-rpi = {
      url = "github:colemickens/Tow-Boot/rpi";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rpipkgs.follows = "rpipkgs";
    };
    tow-boot-radxa-zero = {
      url = "github:colemickens/Tow-Boot/radxa-zero";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tow-boot-radxa-rock5b = {
      url = "github:colemickens/Tow-Boot/radxa-rock5b";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tow-boot-visionfive = {
      url = "github:colemickens/Tow-Boot/visionfive";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mobile-nixos-sdm845 = {
      url = "github:colemickens/mobile-nixos/sdm845-blue";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mobile-nixos-pinephone = {
      url = "github:colemickens/mobile-nixos/pinephone-emmc";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mobile-nixos-openstick = {
      url = "github:colemickens/mobile-nixos/openstick";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nickel = { url = "github:tweag/nickel"; };

    # nix-coreboot.url = "github:colemickens/nix-coreboot";
    # nix-coreboot.inputs.nixpkgs.follows = "nixpkgs";

    terranix.url = "github:terranix/terranix";
    terranix.inputs.nixpkgs.follows = "nixpkgs";

    # provides rust nightly for shells/devenv
    fenix.url = "github:figsoda/fenix";
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    # We're back to using nixUnstable so we shouldn't need this:
    #nix.url = "github:nixos/nix/master";
    #nixpkgs-kubernetes.url = "github:colemickens/nixpkgs-kubernetes/main";
    #nixpkgs-kubernetes.inputs.nixpkgs.follows = "nixpkgs";
    #niche.url = "github:colemickens/niche/master";
    #niche.inputs.nixpkgs.follows = "nixpkgs";
    # construct.url = "github:matrix-construct/construct";
    # construct.inputs.nixpkgs.follows = "nixpkgs";
    # deploy-rs.url = "github:colemickens/deploy-rs";
    # deploy-rs.inputs.nixpkgs.follows = "nixpkgs";
    #nixos-azure.url = "github:colemickens/nixos-azure/dev";
    #nixos-azure.inputs.nixpkgs.follows = "nixpkgs";
    # TODO: use this? or from nixpkgs???
    # envfs.url = "github:Mic92/envfs"; };
    # envfs.inputs.nixpkgs.follows = "nixpkgs";
    # rust-overlay.url = "github:oxalica/rust-overlay"; # TODO: switch frm fenix?
    # wfvm = { url = "https://git.m-labs.hk/M-Labs/wfvm"; type = "git"; flake = false; };
    #nickel.url = "github:tweag/nickel"; };
    #hydra.url = "github:NixOS/hydra"; };
    #hydra.inputs.nixpkgs.follows = "nixpkgs";
  };

  ## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ## NIX_CONFIG
  ## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
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
    # narinfo-cache-negative-ttl = 0;
  };

  ## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ## OUTPUTS
  ## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  outputs = inputs:
    let
      # TODO: further cleanup via usage of "nixlib"
      nixlib = inputs.nixlib.outputs.lib;
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        "riscv64-linux"
        # "riscv64-none-elf" # TODO
        # "armv6l-linux" # eh, I think time is up
        # "armv7l-linux" # eh, I think time is up
      ];
      forAllSystems = nixlib.genAttrs supportedSystems;
      filterPkgTgt = system: (n: p: ("${system}" == p.system) && !(p.meta.broken or false));
      filterPkg_ = system: (n: p: (builtins.elem "${system}" (p.meta.platforms or [ "x86_64-linux" "aarch64-linux" ])) && !(p.meta.broken or false));
      filterPkgs = pkgs: pkgSet: (pkgs.lib.filterAttrs (filterPkg_ pkgs.system) pkgSet);
      filterPkgsTgt = pkgs: pkgSet: (pkgs.lib.filterAttrs (filterPkgTgt pkgs.system) pkgSet);
      filterHosts = pkgs: cfgs: (pkgs.lib.filterAttrs (n: v: pkgs.system == v.config.nixpkgs.system) cfgs);

      colelib = rec {
        force_cached = sys: pkgs_.nixpkgs."${sys}".callPackage ./lib/force_cached.nix { };
        minimalMkShell = system: import ./lib/minimalMkShell.nix { pkgs = fullPkgs_.${system}; };
        hydralib = import ./lib/hydralib.nix;
        pkgsFor = pkgs: system: overlays:
          import pkgs {
            inherit system overlays;
            config.allowUnfree = true;
          };
        pkgs_ = nixlib.genAttrs (builtins.attrNames inputs) (inp: nixlib.genAttrs supportedSystems (sys: pkgsFor inputs."${inp}" sys [ ]));
        fullPkgs_ = nixlib.genAttrs supportedSystems (sys:
          pkgsFor inputs.nixpkgs sys [ inputs.self.overlays.default inputs.nixpkgs-wayland.overlays.default ]);
        mkSystem_ = pkgs: system: h: modules:
          pkgs.lib.nixosSystem {
            system = system;
            modules = [ ./hosts/${h}/configuration.nix ] ++ modules;
            specialArgs = { inherit inputs; };
          };
        mkSystem = pkgs: system: h: (mkSystem_ pkgs system h [ ./hosts/${h}/configuration.nix ]);

        pkgNames = s: builtins.attrNames (inputs.self.overlay pkgs_.${s} pkgs_.${s});
      };

      _inputs = inputs;

    in
    with colelib; rec {
      _ = { inherit inputs colelib nixlib; };

      #################################################################################################################
      ## DEVSHELLS
      #################################################################################################################
      devShells = forAllSystems (system: rec {
        # just the basic tools to run automation for the repo
        # probably not needed/useful super often?
        ci = (import ./shells/ci.nix { inherit inputs system minimalMkShell; });

        # devenv has tooons of dev tools
        # TODO: refactor to share a tool list with `./mixins/devtools.nix`
        devenv = (import ./shells/devenv.nix { inherit inputs system minimalMkShell; });

        # used with webrtcsink project(s):
        # TODO: refactor to compose on top of devenv?
        gstreamer = (import ./shells/gstreamer.nix { inherit inputs system minimalMkShell; });

        # just for fun, imagine our Rust-y future:
        uutils = minimalMkShell system {
          name = "uutils-devshell";
          nativeBuildInputs = with pkgs_.nixpkgs.${system}; [
            (uutils-coreutils.override { prefix = ""; })
            nushell
          ];
          shellHook = ''
            exec nu
          '';
        };
      });

      #################################################################################################################
      ## APPS
      #################################################################################################################
      apps = forAllSystems (system:
        let
          app = program: { type = "app"; program = "${program}"; };
          tfout = import ./cloud { terranix = inputs.terranix; pkgs = pkgs_.nixpkgs.${system}; };

          # mfb = dev: { type = "app"; program = nixosConfigurations.blueline.config.system.build.mobile-flash-boot.outPath; };
          # ds = dev: { type = "app"; program = nixosConfigurations.${dev}.config.system.build.deployScript; };
        in
        (
          {
            # CI (should we use HM for this instead?)
            install-secrets = { type = "app"; program = legacyPackages."${system}".install-secrets.outPath; };

            # Terraform
            tf = { type = "app"; program = tfout.tf.outPath; };
            tf-apply = { type = "app"; program = tfout.apply.outPath; };
            tf-destroy = { type = "app"; program = tfout.destroy.outPath; };
          }
          # // (nixlib.genAttrs [ "blueline" "enchilada" ] mfb)
          # // (nixlib.genAttrs [ "rpithreebp1" ] ds)
        )
      );

      #################################################################################################################
      ## PACKAGES + OVERLAY
      #################################################################################################################
      packages = (forAllSystems (s: (fullPkgs_.${s}.colePackages)));
      pkgs = forAllSystems (s: fullPkgs_.${s});
      overlays = {
        default = (final: prev:
          let p = rec {
            customCommands = prev.callPackage ./pkgs/commands.nix { writePython3Bin = prev.writers.writePython3Bin; };
            customGuiCommands = prev.callPackage ./pkgs/commands-gui.nix { };

            anodium = prev.callPackage ./pkgs/anodium { };
            catacomb = prev.callPackage ./pkgs/catacomb { };
            get-xoauth2-token = prev.callPackage ./pkgs/get-xoauth2-token { };
            hodd = prev.callPackage ./pkgs/hodd { };
            keyboard-layouts = prev.callPackage ./pkgs/keyboard-layouts { };
            onionbalance = prev.python3Packages.callPackage ./pkgs/onionbalance { };
            # rumqtt = prev.callPackage ./pkgs/rumqtt { };
            solo2-cli = prev.callPackage ./pkgs/solo2-cli {
              solo2-cli = prev.solo2-cli;
            };
            space-cadet-pinball = prev.callPackage ./pkgs/space-cadet-pinball { };
            space-cadet-pinball-unfree = prev.callPackage ./pkgs/space-cadet-pinball {
              _assets = import ./pkgs/space-cadet-pinball/assets.nix { pkgs = prev; };
            };
            shreddit = prev.python3Packages.callPackage ./pkgs/shreddit { };
            # tvp = prev.callPackage ./pkgs/tvp { };
            rsntp = prev.callPackage ./pkgs/rsntp { };
            # rtsp-simple-server = prev.callPackage ./pkgs/rtsp-simple-server {
            #   buildGoModule = prev.buildGo117Module;
            # };
            visualizer2 = prev.callPackage ./pkgs/visualizer2 { };

            nix-build-uncached = prev.nix-build-uncached.overrideAttrs (old: {
              src = prev.fetchFromGitHub {
                owner = "colemickens";
                repo = "nix-build-uncached";
                rev = "0edd782cb419ccb537ac11b1d98ab0f4fb9c9537";
                sha256 = "sha256-xqD6aSyZzfyhZg2lYrhBXvU45bM8Bfttcnngqk8XXkk=";
              };
            });

            # alacritty/bottom/wezterm - rust updates are ... maybe not working? so...
            # disabled (not sure how to add rocksdb) # conduit = prev.callPackage ./pkgs/conduit {};
          }; in p // { colePackages = p; }
        );
      };

      #################################################################################################################
      ## NIXOS_MODULES
      #################################################################################################################
      nixosModules = {
        #   hydra-auto = import ./modules/hydra-auto.nix;
        #   otg = import ./modules/otg.nix;
        #   other-arch-vm = import ./modules/other-arch-vm.nix;
      };

      #################################################################################################################
      ## NIXOS CONFIGS + TOPLEVELS
      #################################################################################################################
      nixosConfigs = {
        misc = {
          installer = mkSystem inputs.nixpkgs "x86_64-linux" "installer";
        };
        phone = {
          # native targets for building "big" stage-2s on actual aarch64 hardware:
          pinephone = mkSystem inputs.nixpkgs "aarch64-linux" "pinephone";
          blueline = mkSystem inputs.nixpkgs "aarch64-linux" "blueline";
          enchilada = mkSystem inputs.nixpkgs "aarch64-linux" "enchilada";
          # we need cross-targets sometimes to be able to easily build full "partitions" locally:
          x_pinephone = mkSystem inputs.nixpkgs "x86_64-linux" "pinephone";
          x_blueline = mkSystem inputs.nixpkgs "x86_64-linux" "blueline";
          x_enchilada = mkSystem inputs.nixpkgs "x86_64-linux" "enchilada";
        };
        sbc = {
          risky = mkSystem inputs.cross-riscv64 "riscv64-linux" "risky";
          x_risky = mkSystem inputs.cross-riscv64 "x86_64-linux" "risky";
          radxazero1 = mkSystem inputs.rpipkgs "aarch64-linux" "radxazero1";
          rpifour1 = mkSystem inputs.rpipkgs "aarch64-linux" "rpifour1";
          rpithreebp1 = mkSystem inputs.rpipkgs "aarch64-linux" "rpithreebp1";
          rpizerotwo1 = mkSystem inputs.rpipkgs "aarch64-linux" "rpizerotwo1";
          openstick = mkSystem inputs.nixpkgs "x86_64-linux" "openstick";
        };
        pc = {
          carbon = mkSystem inputs.nixpkgs "x86_64-linux" "carbon";
          jeffhyper = mkSystem inputs.nixpkgs "x86_64-linux" "jeffhyper";
          slynux = mkSystem inputs.nixpkgs "x86_64-linux" "slynux";
          raisin = mkSystem inputs.nixpkgs "x86_64-linux" "raisin";
          xeep = mkSystem inputs.nixpkgs "x86_64-linux" "xeep";
        };
      };
      nixosConfigurations = (nixosConfigs.pc // nixosConfigs.sbc // nixosConfigs.phone // nixosConfigs.misc); # TODO: automate/map/flatten
      toplevels = nixlib.genAttrs
        (builtins.attrNames inputs.self.outputs.nixosConfigurations)
        (attr: nixosConfigurations.${attr}.config.system.build.toplevel);

      ## NETBOOTS
      netboots = {};
      # netboots = netboots_;
      netboots_ = nixlib.genAttrs
        [ "rpifour1" ]
        # [ "x_risky" "rpifour1" "rpithreebp1" "rpizerotwo1" ]
        (h: nixosConfigurations.${h}.config.system.build.extras.nfsboot);


      #################################################################################################################
      ## HYDRA JOBS / BUNDLES / LEGACY_PACKAGES
      #################################################################################################################
      legacyPackages = (forAllSystems (s: {
        # legacyPackages contains references to packages, thus inf recursion otherwise
        cache-dev = bundles.${s}.devShells;
        cache-all = pkgs_.nixpkgs.${s}.linkFarmFromDrvs "cache-all-${s}" [
          bundles.${s}.devShells
          bundles.${s}.packages
          bundles.${s}.toplevels_pc
        ];
      }));
      hydraJobs = forAllSystems (s: {
        devShells = force_cached s (builtins.mapAttrs (n: v: v.inputDerivation) inputs.self.devShells.${s});
        packages = force_cached s (filterPkgs pkgs_.nixpkgs.${s} inputs.self.packages.${s});
        toplevels = force_cached s (builtins.mapAttrs (n: v: v.config.system.build.toplevel)
          (filterHosts pkgs_.nixpkgs.${s} inputs.self.nixosConfigurations));
        toplevels_pc = force_cached s (builtins.mapAttrs (n: v: v.config.system.build.toplevel)
          (filterHosts pkgs_.nixpkgs.${s} inputs.self.nixosConfigs.pc));
        toplevels_phone = force_cached s (builtins.mapAttrs (n: v: v.config.system.build.toplevel)
          (filterHosts pkgs_.nixpkgs.${s} inputs.self.nixosConfigs.phone));
        netboots = force_cached s (filterPkgsTgt pkgs_.nixpkgs.${s} netboots);
      });
      # # TODO: finish this...
      # # most unused because its rare everything is building...
      bundles = forAllSystems (s: (
        pkgs_.nixpkgs.${s}.lib.mapAttrs
          (n: v:
            (pkgs_.nixpkgs.${s}.linkFarmFromDrvs "${n}-bundle"
              (builtins.attrValues v))
          )
          inputs.self.hydraJobs.${s}
      ));

      #################################################################################################################
      ## CURATED PAYLOADS
      #################################################################################################################
      installer = nixosConfigurations.installer.config.system.build.isoImage;
      phones = (
        let
          phoneNamesAndroid = [ "blueline" "enchilada" ];
          phoneNamesUboot = [ "pinephone" ];
          mkAndroidPhone = phname: {
            bootimg = nixosConfigurations."${phname}-cross".config.mobile.outputs.android.android-bootimg;
            rootimg = nixosConfigurations."${phname}-cross".config.mobile.outputs.android.android-rootfs;
            fastboot = nixosConfigurations."${phname}-cross".config.mobile.outputs.android.android-fastboot-images;
            reset-script = nixosConfigurations."${phname}-cross".config.mobile.outputs.android.reset-script;
          };
          mkUbootPhone = phname: {
            boot-partition = nixosConfigurations."${phname}-cross".config.mobile.outputs.u-boot.boot-partition;
            disk-image = nixosConfigurations."${phname}-cross".config.mobile.outputs.u-boot.disk-image;
          };
        in
        (
          (nixlib.genAttrs phoneNamesAndroid mkAndroidPhone)
          // (nixlib.genAttrs phoneNamesUboot mkUbootPhone)
        )
      );
      sbc = {
        openstick = {
          aboot = nixosConfigurations.openstick.config.mobile.outputs.android.android-abootimg;
          fastboot-images = nixosConfigurations.openstick.config.mobile.outputs.android.android-fastboot-images;
        };
        radxa-zero1 = {
          uboot = {};
        };
        radxa-rock5b = {
          # TODO: finish up tow-boot build
          # TODO: kernel reference here: https://github.com/samueldr-wip/wip-nixos-on-arm/tree/wip/rock5
          uboot = nixosConfigurations.rock5b.config.system.build.tow-boot.outputs.Tow-Boot.disk-image;
        };
      };
    };
}
