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
  };

  ## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  ## OUTPUTS
  ## ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  outputs = inputs:
    let
      lib = inputs.lib-aggregate.lib;
      hydralib = import ./lib/hydralib.nix;
      flake-utils = inputs.nixlib.lib.flake-utils;

      mkSystem = n: v: (v.pkgs.lib.nixosSystem ({
        system = v.sys;
        modules = [ ./hosts/${n}/configuration.nix ];
        specialArgs = { inherit inputs; };
      }));
      mkToplevel = v: ((mkSystem v).config.system.build.toplevel);

      #################################################################################################################
      ## NIXOS CONFIGS + TOPLEVELS
      #################################################################################################################
      nixosConfigsEx = {
        misc = {
          # installer = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; host = "installer"; };
        };
        phone = rec {
          pinephone = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; slug = "pinephone"; };
          blueline = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; slug = "blueline"; };
          enchilada = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; slug = "enchilada"; };
          # x_pinephone = pinephone // { sys = "x86_64-linux"; };
          # x_blueline = blueline // { sys = "x86_64-linux"; };
          # x_enchilada = enchilada // { sys = "x86_64-linux"; };
        };
        sbc = rec {
          radxazero1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; slug = "radxazero1"; };
          rpifour1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; slug = "rpifour1 "; };
          rpithreebp1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; slug = "rpithreebp1"; };
          rpizerotwo1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; slug = "rpizerotwo1"; };
          # openstick = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; slug = "openstick"; };
          openstick = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; slug = "openstick"; };
          visionfive1 = { pkgs = inputs.nixpkgs; sys = "riscv64-linux"; slug = "visionfive1"; };
        };
        pc = {
          carbon = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; slug = "carbon"; };
          jeffhyper = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; slug = "jeffhyper"; };
          slynux = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; slug = "slynux"; };
          raisin = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; slug = "raisin"; };
          xeep = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; slug = "xeep"; };
        };
      };

      nixosConfigs = (lib.foldl' (op: nul: nul // op) { } (lib.attrValues nixosConfigsEx));
      nixosConfigurations = (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigs);
      toplevels = (lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations);

      ## SPECIAL OUTPUTS:
      images = {
        openstick = {
          inherit (nixosConfigurations.openstick.config.mobile.outputs.android)
            android-flashable-system android-flashable-bootimg android-abootimg/*android-bootimg*/;
        };
        # eche96 = nixosConfigurations.openstick.config.mobile.outputs.android;
      };
      imagePackages = (lib.foldl' (op: nul: nul // op) { } (lib.attrValues images));
    in
    ({
      ## PASSTHROUGH ##################################################################################################
      inherit inputs lib hydralib;
      inherit nixosConfigsEx nixosConfigs nixosConfigurations toplevels;

      ## CUSTOM PAYLOADS ##############################################################################################
      # installer = nixosConfigurations.installer.config.system.build.isoImage;
      inherit images;

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

              default = {
                type = "app";
                program = (pkgs.writeScript "nixcfg-main" ''
                  exec "${pkgs.nushell}/bin/nu" "${./. + "/main.nu"}" "''${@}"
                '').outPath;
              };

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
          ## CI JOBS
          #################################################################################################################
          ciJobs = {
            default = ({ }
            // (lib.genAttrs [ "devtools" "ci" "devenv" ] (name: inputs.self.devShells.${system}.${name}.inputDerivation))
            // (inputs.self.packages.${system})
            // (lib.mapAttrs
              (n: v: toplevels."${n}")
              (lib.filterAttrs (n: v: v.sys == system) nixosConfigs)
            )
            # we don't necessarily want to push 1GB packages to cachix:
            # // (lib.filterAttrs (n: v: v.system == system) imagePackages)
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
