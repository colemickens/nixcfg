{
  description = "colemickens-nixcfg";

  inputs = {
    lib-aggregate = { url = "github:nix-community/lib-aggregate"; }; #TODO: boo name! "libaggregate"?

    nixpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; };
    nixpkgs-stable = { url = "github:nixos/nixpkgs/nixos-22.05"; }; # any stable to use
    nixpkgs-cross = { url = "github:colemickens/nixpkgs/cmpkgs-cross"; }; # base for cross-compiling fixes (used directly for aarch64 and riscv64-branch)
    nixpkgs-cross-riscv64 = { url = "github:colemickens/nixpkgs/cmpkgs-cross-riscv64"; };
    nixpkgs-rpipkgs = { url = "github:colemickens/nixpkgs/cmpkgs-rpipkgs"; };

    home-manager = { url = "github:colemickens/home-manager/cmhm"; inputs."nixpkgs".follows = "nixpkgs"; };
    nixos-hardware = { url = "github:nixos/nixos-hardware"; };
    nixpkgs-wayland = { url = "github:colemickens/nixpkgs-wayland/master"; inputs."nixpkgs".follows = "nixpkgs"; };
    # TODO: promote this to a nix-community project, it's neat, can combine with HM modules, etc  --- another maybe okayish way to bring folks in
    # TODO: rename, nix-rice is active again and my this is mostly just the colorschemes and an import... :p
    #   -- maybe the appearance module idea manifests there?
    nix-rice = { url = "github:colemickens/nix-rice"; inputs."nixpkgs".follows = "nixpkgs"; };
    firefox-nightly = { url = "github:colemickens/flake-firefox-nightly"; inputs."nixpkgs".follows = "nixpkgs"; };
    terranix = { url = "github:terranix/terranix"; inputs.nixpkgs.follows = "nixpkgs"; };

    visionfive-nix = { url = "github:colemickens/visionfive-nix"; inputs."nixpkgs".follows = "nixpkgs-cross-riscv64"; };
    nixos-riscv64 = { url = "github:colemickens/nixos-riscv64"; inputs."nixpkgs".follows = "nixpkgs-cross-riscv64"; };

    impermanence = { url = "github:nix-community/impermanence"; }; # TODO: use it or lose it
    nickel = { url = "github:tweag/nickel"; };
    fenix = { url = "github:figsoda/fenix"; inputs."nixpkgs".follows = "nixpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix/master"; inputs."nixpkgs".follows = "nixpkgs"; };

    # transient deps, de-dupe here
    # rust-overlay = { url = ""; };

    # devtools:
    helix = { url = "github:helix-editor/helix"; inputs."nixpkgs".follows = "nixpkgs"; };
    jj = { url = "github:martinvonz/jj"; inputs."nixpkgs".follows = "nixpkgs"; };
    # marksman = { url = "github:the-mikedavis/marksman/flake"; inputs."nixpkgs".follows = "nixpkgs"; };
    nix-eval-jobs = { url = "github:nix-community/nix-eval-jobs"; inputs."nixpkgs".follows = "nixpkgs"; };
    # zellij = {
    #   url = "github:zellij-org/zellij/6a5e15edf33c034b049a866f8628968b5168c533";
    #   inputs."nixpkgs".follows = "nixpkgs";
    #   # inputs."rust-overlay".follows = "rust-overlay";
    # };

    # experimental:
    hyprland = { url = "github:hyprwm/Hyprland"; inputs."nixpkgs".follows = "nixpkgs"; };
    nix-netboot-server = { url = "github:DeterminateSystems/nix-netboot-serve"; };

    # WIP: tow-boot/mobile-nixos stuffs:
    tow-boot-rpi = {
      url = "github:colemickens/Tow-Boot/rpi";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rpipkgs.follows = "nixpkgs-rpipkgs";
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
    mobile-nixos-reset-scripts = {
      url = "github:colemickens/mobile-nixos/reset-scripts";
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

    # TODO: revisit/checkout: mic92/envfs, nickel, wfvm
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
        system = v.sys;
        modules = [ ./hosts/${n}/configuration.nix ];
        specialArgs = { inherit inputs; };
      }));

      ## NIXOS CONFIGS + TOPLEVELS ############################################
      nixosConfigsEx = {
        misc = {
          installer = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
        };
        phone = {
          pinephone = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          blueline = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
        };
        sbc = {
          radxazero1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          rockfiveb1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          openstick = { pkgs = inputs.nixpkgs-cross; sys = "x86_64-linux"; };
          aitchninesix1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          rpifour1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          rpithreebp1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          rpizerotwo1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          visionfiveone1 = { pkgs = inputs.nixpkgs-cross-riscv64; sys = "x86_64-linux"; };
          visionfivetwo1 = { pkgs = inputs.nixpkgs-cross-riscv64; sys = "x86_64-linux"; };
        };
        pc = {
          carbon = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
          jeffhyper = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
          raisin = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
          slynux = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
          xeep = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
          # zeph = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
        };
      };

      nixosConfigs = (lib.foldl' (op: nul: nul // op) { } (lib.attrValues nixosConfigsEx));
      deployConfigs = {
        inherit (nixosConfigs)
          carbon
          raisin
          # slynux # defunct, or soon to be
          jeffhyper
          xeep
          # zeph # new
          radxazero1
          rockfiveb1
          # visionfivetwo1
          # rpizerotwo1 # broken??
          # blueline
          # pinephone
          # rpifour1 # netboot
          # rpithreebp1 # netboot
          # visionfiveone1 # netboot
          openstick
          ;
      };
      nixosConfigurations = (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigs);
      toplevels = (lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations);

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

        # blueline = let o = (mkSystem "blueline" { sys = "x86_64-linux"; pkgs = inputs.nixpkgs; }).config; in {
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
              extract-xiso = prev.callPackage ./pkgs/pkgs/extract-xiso { };
              nushell = prev.callPackage ./pkgs/pkgs/nushell {
                inherit (prev.darwin.apple_sdk.frameworks) AppKit Foundation Security;
                inherit (prev.darwin.apple_sdk) sdk;
              };
              # space-cadet-pinball = prev.callPackage ./pkgs/pkgs/space-cadet-pinball { };
              # space-cadet-pinball-unfree = prev.callPackage ./pkgs/pkgs/space-cadet-pinball {
              #   _assets = import ./pkgs/pkgs/space-cadet-pinball/assets.nix { pkgs = prev; };
              # };
              wezterm = prev.darwin.apple_sdk_11_0.callPackage ./pkgs/pkgs/wezterm {
                inherit (prev.darwin.apple_sdk_11_0.frameworks) Cocoa CoreGraphics Foundation UserNotifications;
              };
              visualizer2 = prev.callPackage ./pkgs/pkgs/visualizer2 { };
            };
          in
          __colemickens_nixcfg_pkgs // { inherit __colemickens_nixcfg_pkgs; });
      };
    in
    lib.recursiveUpdate
      ({
        inherit nixosConfigsEx nixosConfigs nixosConfigurations deployConfigs toplevels;
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
            pkgsFree = pkgs_ inputs.nixpkgs { };
            pkgsUnfree = pkgs_ inputs.nixpkgs { allowUnfree = true; };
            pkgsStable = pkgs_ inputs.nixpkgs-stable { };
            pkgs = pkgsFree;
            mkShell = (name: import ./shells/${name}.nix { inherit inputs pkgs; });
            # mkAppScript = (name: script: {
            #   type = "app";
            #   program = (pkgsStable.writeScript "${name}.sh" script).outPath;
            # });
          in
          rec {
            inherit pkgs pkgsStable pkgsUnfree;

            ## DEVSHELLS # some of 'em kinda compose #############################
            devShells = (lib.genAttrs [ "ci" "devenv" "devtools" "gstreamer" "uutils" ] mkShell)
              // { default = devShells.devtools; };

            ## APPS ##############################################################
            apps = lib.recursiveUpdate
              ({
                # TODO: this definitely goes somewhere else:
                # rockfiveb1_install = let f = images.rockfiveb1.installFiles; in
                #   mkAppScript "rockfiveb1_install" ''
                #     set -x
                #     set -euo pipefail
                #     rm -f result
                #     ./main.nu cachedl 'images.aitchninesix1.installFiles'
                #     out="$(readlink result)"
                #     sudo rsync -avh --delete "$out/boot/" "/tmp/mnt-boot/"
                #     sudo rsync -avh "$out/root/" "/tmp/mnt-root/"
                #     sudo nix copy "''$(cat "$out/root/toplevel")" \
                #       --no-check-sigs \
                #       --to /tmp/mnt-root
                #   '';
              })
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
            ciJobs = {
              default = ({ }
                // (lib.genAttrs [ "devtools" "ci" "devenv" ] (name: inputs.self.devShells.${system}.${name}.inputDerivation))
                // (inputs.self.packages.${system})
                // (lib.mapAttrs
                (n: v: toplevels."${n}")
                (lib.filterAttrs (n: v: v.sys == system) nixosConfigs))
              );
            };
          })
      )
  ;
}
