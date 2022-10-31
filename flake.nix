{
  description = "colemickens-nixcfg";

  inputs = {
    nixlib = { url = "github:nix-community/nixpkgs.lib"; }; #TODO: boo name! "libaggregate"?
    lib-aggregate = { url = "github:nix-community/lib-aggregate"; }; #TODO: boo name! "libaggregate"?

    nixpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; };
    cross-armv6l = { url = "github:colemickens/nixpkgs/cmpkgs-cross-armv6l"; };
    cross-riscv64 = { url = "github:colemickens/nixpkgs/cmpkgs-cross-riscv64"; };
    rpipkgs = { url = "github:colemickens/nixpkgs/cmpkgs-rpipkgs"; };

    home-manager = { url = "github:colemickens/home-manager/cmhm"; inputs."nixpkgs".follows = "nixpkgs"; };
    nixos-hardware = { url = "github:nixos/nixos-hardware"; };
    nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland/master"; inputs."nixpkgs".follows = "nixpkgs"; };
    # TODO: promote this to a nix-community project, it's neat, can combine with HM modules, etc  --- another maybe okayish way to bring folks in
    nix-rice = { url = "github:colemickens/nix-rice"; inputs."nixpkgs".follows = "nixpkgs"; };
    firefox-nightly = { url = "github:colemickens/flake-firefox-nightly"; inputs."nixpkgs".follows = "nixpkgs"; };
    terranix = { url = "github:terranix/terranix"; inputs.nixpkgs.follows = "nixpkgs"; };

    visionfive-nix = { url = "github:colemickens/visionfive-nix"; inputs."nixpkgs".follows = "cross-riscv64"; };
    # nixos-riscv64.url = "https://github.com/colemickens/nixos-riscv64";
    # jh7100.url = "https://github.com/colemickens/jh7100";

    impermanence = { url = "github:nix-community/impermanence"; };
    nickel = { url = "github:tweag/nickel"; };
    fenix = { url = "github:figsoda/fenix"; inputs."nixpkgs".follows = "nixpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix/master"; inputs."nixpkgs".follows = "nixpkgs"; };

    # devtools:
    helix = { url = "github:helix-editor/helix"; inputs."nixpkgs".follows = "nixpkgs"; };
    jj = { url = "github:martinvonz/jj"; inputs."nixpkgs".follows = "nixpkgs"; };
    zellij = { url = "github:zellij-org/zellij"; };
    marksman = { url = "github:the-mikedavis/marksman/flake"; inputs."nixpkgs".follows = "nixpkgs"; };
    # (todo):
    nix-eval-jobs = { url = "github:nix-community/nix-eval-jobs"; inputs."nixpkgs".follows = "nixpkgs"; };

    # experimental:
    hyprland = { url = "github:hyprwm/Hyprland"; inputs."nixpkgs".follows = "nixpkgs"; };
    nix-netboot-server = { url = "github:DeterminateSystems/nix-netboot-serve"; };

    # WIP: tow-boot/mobile-nixos stuffs:
    tow-boot-rpi = {
      url = "github:colemickens/Tow-Boot/rpi";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rpipkgs.follows = "rpipkgs";
    };
    tow-boot-radxa-zero = {
      url = "github:colemickens/Tow-Boot/radxa-zero";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # tow-boot-radxa-rock5b = {
    #   url = "github:colemickens/Tow-Boot/radxa-rock5b";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
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
      lib = inputs.lib-aggregate.lib;
      hydralib = import ./lib/hydralib.nix;
      flake-utils = inputs.nixlib.lib.flake-utils;

      mkSystem = v: (v.pkgs.lib.nixosSystem ({
        system = v.sys;
        modules = [ ./hosts/${v.host}/configuration.nix ];
        specialArgs = { inherit inputs; };
      }));
      mkToplevel = v: (mkSystem v).config.system.build.toplevel;

      #################################################################################################################
      ## NIXOS CONFIGS + TOPLEVELS
      #################################################################################################################
      nixosConfigs = rec {
        misc = {
          # installer = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; host = "installer"; };
        };
        phone = rec {
          pinephone = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; host = "pinephone"; };
          blueline = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; host = "blueline"; };
          enchilada = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; host = "enchilada"; };
          # x_pinephone = pinephone // { sys = "x86_64-linux"; };
          # x_blueline = blueline // { sys = "x86_64-linux"; };
          # x_enchilada = enchilada // { sys = "x86_64-linux"; };
        };
        sbc = rec {
          risky = { pkgs = inputs.nixpkgs; sys = "riscv64-linux"; host = "risky"; };
          radxazero1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; host = "radxazero1"; };
          rpifour1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; host = "rpifour1 "; };
          rpithreebp1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; host = "rpithreebp1"; };
          rpizerotwo1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; host = "rpizerotwo1"; };
          openstick = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; host = "openstick"; };
          # x_risky = risky // { sys = "x86_64-linux"; };
        };
        pc = {
          carbon = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; host = "carbon"; };
          jeffhyper = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; host = "jeffhyper"; };
          slynux = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; host = "slynux"; };
          raisin = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; host = "raisin"; };
          xeep = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; host = "xeep"; };
        };
        _all = (misc // phone // sbc // pc);
      };
      nixosConfigurations = (lib.mapAttrs (_: v: (mkSystem v)) nixosConfigs._all);
      toplevels = (lib.mapAttrs (_: v: (mkToplevel v)) nixosConfigs._all);

    in
    ({
      ## PASSTHROUGH ##################################################################################################
      inherit inputs lib hydralib;
      inherit toplevels nixosConfigs nixosConfigurations;

      ## CUSTOM PAYLOADS ##############################################################################################
      # installer = nixosConfigurations.installer.config.system.build.isoImage;

      ## NIXOS_MODULES ################################################################################################
      nixosModules = {
        #   hydra-auto = import ./modules/hydra-auto.nix;
        #   otg = import ./modules/otg.nix;
        #   other-arch-vm = import ./modules/other-arch-vm.nix;
      };

      #################################################################################################################
      ## OVERLAY
      #################################################################################################################
      overlays = {
        default = (final: prev: {
          anodium = prev.callPackage ./pkgs/anodium { };
          catacomb = prev.callPackage ./pkgs/catacomb { };
          get-xoauth2-token = prev.callPackage ./pkgs/get-xoauth2-token { };
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

          # nix-build-uncached = prev.nix-build-uncached.overrideAttrs (old: {
          #   src = prev.fetchFromGitHub {
          #     owner = "colemickens";
          #     repo = "nix-build-uncached";
          #     rev = "0edd782cb419ccb537ac11b1d98ab0f4fb9c9537";
          #     sha256 = "sha256-xqD6aSyZzfyhZg2lYrhBXvU45bM8Bfttcnngqk8XXkk=";
          #   };
          # });
        });
      };
    }) //
    (
      #################################################################################################################
      ## SYSTEM-SPECIFIC
      #################################################################################################################
      lib.flake-utils.eachSystem [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ] (system:
        let
          pkgs = import inputs.nixpkgs { inherit system; };
          pkgs_ = import inputs.nixpkgs { inherit system; config.allowUnfree = true; };
          fullPkgs = import inputs.nixpkgs { inherit system; config.overlays = [ inputs.self.overlays.default inputs.nixpkgs-wayland.overlays.default ]; };

          fcd = pkgs.callPackage ./lib/force_cached.nix { };
          filterPkgSystem = _p: lib.filterAttrs (n: v: (system) == _p.system); # can't we check pkg outptu system attr like evreything else
        in
        {
          #################################################################################################################
          ## DEVSHELLS
          ## - devtools's nativeBuildInputs are also included in `shells/devenv.nix` and in `profiles/dev.nix`
          #################################################################################################################
          devShells = lib.genAttrs [ "ci" "devenv" "devtools" "gstreamer" "uutils" ] (name: import ./shells/${name}.nix {
            inherit inputs system;
            minimalMkShell = (import ./lib/minimalMkShell.nix { inherit pkgs; });
          });

          #################################################################################################################
          ## APPS
          #################################################################################################################
          apps =
            let
              tfout = import ./cloud { terranix = inputs.terranix; inherit pkgs; };
            in
            ({
              # CI (should we use HM for this instead?)
              # install-secrets = { type = "app"; program = legacyPackages."${system}".install-secrets.outPath; };

              # Terraform
              tf = { type = "app"; program = tfout.tf.outPath; };
              tf-apply = { type = "app"; program = tfout.apply.outPath; };
              tf-destroy = { type = "app"; program = tfout.destroy.outPath; };
            });

          #################################################################################################################
          ## PACKAGES
          # - `packages` follows flake convention -- packages provided by our overlay
          # - `pkgs` is overlayed nixpkgs (nixpkgs-wayland, nixcfg->overlay)
          # - `fullPkgs` is non-free nixpkgs
          #################################################################################################################
          packages = (inputs.self.overlays.default (pkgs_) (pkgs_));
          inherit pkgs fullPkgs;

          #################################################################################################################
          ## DEFUNCT
          #################################################################################################################
          # ## NETBOOTS
          # netboots = { };
          # # netboots = netboots_;
          # netboots_ = lib.genAttrs
          #   [ "rpifour1" ]
          #   # [ "x_risky" "rpifour1" "rpithreebp1" "rpizerotwo1" ]
          #   (h: nixosConfigurations.${h}.config.system.build.extras.nfsboot);
          #################################################################################################################


          #################################################################################################################
          ## HYDRA JOBS / BUNDLES / LEGACY_PACKAGES
          #################################################################################################################
          # legacyPackages = (forAllSystems (s: {
          #   # legacyPackages contains references to packages, thus inf recursion otherwise
          #   cache-dev = bundles.${s}.devShells;
          #   cache-all = pkgs_.nixpkgs.${s}.linkFarmFromDrvs "cache-all-${s}" [
          #     bundles.${s}.devShells
          #     bundles.${s}.packages
          #     bundles.${s}.toplevels_pc
          #   ];
          # }));

          ciJobs = {
            default = ({ }
            // (lib.genAttrs [ "devtools" "ci" "devenv" ] (name: inputs.self.devShells.${system}.${name}.inputDerivation))
            // (inputs.self.packages.${system})
            // (lib.mapAttrs (_: v: mkToplevel v) (lib.filterAttrs (n: v: v.sys == system) nixosConfigs._all))
            );
          };


          #################################################################################################################
          ## CURATED PAYLOADS
          #################################################################################################################
          # phones = (
          #   let
          #     phoneNamesAndroid = [ "blueline" "enchilada" ];
          #     phoneNamesUboot = [ "pinephone" ];
          #     mkAndroidPhone = phname: {
          #       bootimg = nixosConfigurations."${phname}-cross".config.mobile.outputs.android.android-bootimg;
          #       rootimg = nixosConfigurations."${phname}-cross".config.mobile.outputs.android.android-rootfs;
          #       fastboot = nixosConfigurations."${phname}-cross".config.mobile.outputs.android.android-fastboot-images;
          #       reset-script = nixosConfigurations."${phname}-cross".config.mobile.outputs.android.reset-script;
          #     };
          #     mkUbootPhone = phname: {
          #       boot-partition = nixosConfigurations."${phname}-cross".config.mobile.outputs.u-boot.boot-partition;
          #       disk-image = nixosConfigurations."${phname}-cross".config.mobile.outputs.u-boot.disk-image;
          #     };
          #   in
          #   (
          #     (lib.genAttrs phoneNamesAndroid mkAndroidPhone)
          #     // (lib.genAttrs phoneNamesUboot mkUbootPhone)
          #   )
          # );
          # sbc = {
          #   openstick = {
          #     aboot = nixosConfigurations.openstick.config.mobile.outputs.android.android-abootimg;
          #     fastboot-images = nixosConfigurations.openstick.config.mobile.outputs.android.android-fastboot-images;
          #   };
          #   radxa-zero1 = {
          #     uboot = { };
          #   };
          #   radxa-rock5b = {
          #     # TODO: finish up tow-boot build
          #     # TODO: kernel reference here: https://github.com/samueldr-wip/wip-nixos-on-arm/tree/wip/rock5
          #     uboot = nixosConfigurations.rock5b.config.system.build.tow-boot.outputs.Tow-Boot.disk-image;
          #   };
          # };
        })
    );
}
