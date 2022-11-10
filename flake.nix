{
  description = "colemickens-nixcfg";

  inputs = {
    lib-aggregate = { url = "github:nix-community/lib-aggregate"; }; #TODO: boo name! "libaggregate"?

    nixpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; };
    cross-armv6l = { url = "github:colemickens/nixpkgs/cmpkgs-cross-armv6l"; };
    cross-riscv64 = { url = "github:colemickens/nixpkgs/cmpkgs-cross-riscv64"; };
    rpipkgs = { url = "github:colemickens/nixpkgs/cmpkgs-rpipkgs"; };

    home-manager = { url = "github:colemickens/home-manager/cmhm"; inputs."nixpkgs".follows = "nixpkgs"; };
    nixos-hardware = { url = "github:nixos/nixos-hardware"; };
    nixpkgs-wayland = { url = "github:nix-community/nixpkgs-wayland/master"; inputs."nixpkgs".follows = "nixpkgs"; };
    # TODO: promote this to a nix-community project, it's neat, can combine with HM modules, etc  --- another maybe okayish way to bring folks in
    # TODO: rename, nix-rice is active again and my this is mostly just the colorschemes and an import... :p
    #   -- maybe the appearance module idea manifests there?
    nix-rice = { url = "github:colemickens/nix-rice"; inputs."nixpkgs".follows = "nixpkgs"; };
    firefox-nightly = { url = "github:colemickens/flake-firefox-nightly"; inputs."nixpkgs".follows = "nixpkgs"; };
    terranix = { url = "github:terranix/terranix"; inputs.nixpkgs.follows = "nixpkgs"; };

    visionfive-nix = { url = "github:colemickens/visionfive-nix"; inputs."nixpkgs".follows = "cross-riscv64"; };
    # nixos-riscv64.url = "https://github.com/colemickens/nixos-riscv64";
    # jh7100.url = "https://github.com/colemickens/jh7100";

    impermanence = { url = "github:nix-community/impermanence"; }; # TODO: use it or lose it
    nickel = { url = "github:tweag/nickel"; };
    fenix = { url = "github:figsoda/fenix"; inputs."nixpkgs".follows = "nixpkgs"; };
    sops-nix = { url = "github:Mic92/sops-nix/master"; inputs."nixpkgs".follows = "nixpkgs"; };

    # transient deps, de-dupe here
    # rust-overlay = { url = ""; };

    # devtools:
    helix = { url = "github:helix-editor/helix"; inputs."nixpkgs".follows = "nixpkgs"; };
    jj = { url = "github:martinvonz/jj"; inputs."nixpkgs".follows = "nixpkgs"; };
    marksman = { url = "github:the-mikedavis/marksman/flake"; inputs."nixpkgs".follows = "nixpkgs"; };
    nix-eval-jobs = { url = "github:nix-community/nix-eval-jobs"; inputs."nixpkgs".follows = "nixpkgs"; };
    zellij = {
      url = "github:zellij-org/zellij";
      inputs."nixpkgs".follows = "nixpkgs";
      # inputs."rust-overlay".follows = "rust-overlay";
    };

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
      mkToplevel = v: ((mkSystem v).config.system.build.toplevel);

      ## NIXOS CONFIGS + TOPLEVELS ############################################
      nixosConfigsEx = {
        misc = {
          # installer = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; host = "installer"; };
        };
        phone = rec {
          # pinephone = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          # blueline = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          # enchilada = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          # x_pinephone = pinephone // { sys = "x86_64-linux"; };
          # x_blueline = blueline // { sys = "x86_64-linux"; };
          # x_enchilada = enchilada // { sys = "x86_64-linux"; };
        };
        sbc = rec {
          radxazero1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          rockfiveb1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          rpifour1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          rpithreebp1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          rpizerotwo1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          openstick = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
          # visionfiveone1 = { pkgs = inputs.cross-riscv64; sys = "riscv64-linux"; };
          # visionfiveone1 = { pkgs = inputs.cross-riscv64; sys = "x86_64-linux"; };
        };
        pc = {
          carbon = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
          jeffhyper = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
          slynux = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
          raisin = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
          xeep = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
        };
      };

      nixosConfigs = (lib.foldl' (op: nul: nul // op) { } (lib.attrValues nixosConfigsEx));
      nixosConfigurations = (lib.mapAttrs (n: v: (mkSystem n v)) nixosConfigs);
      toplevels = (lib.mapAttrs (_: v: v.config.system.build.toplevel) nixosConfigurations);

      ## SPECIAL OUTPUTS ######################################################
      images = let cfg = n: nixosConfigurations."${n}".config; in
        {
          # installer = (cfg "installer").config.system.build.isoImage;
          openstick = let o = (cfg "openstick"); in
            {
              aboot = o.mobile.outputs.android.android-abootimg;
              boot = o.mobile.outputs.android.android-bootimg;
              # 'fastboot flash -S 100M $rootfs/NIXOS_SYSTEM.img'
              rootfs = o.mobile.outputs.generatedFilesystems.rootfs;
            };
          rockfiveb1 = let o = (cfg "rockfiveb1"); in
            {
              #TODO: major issue, this is diff:
              tb = o.system.build.tow-boot.outputs.diskImage;
              # tb = o.system.build.tow-boot.outputs.firmware;
              # rootfs = o.mobile.outputs.generatedFilesystems.rootfs;
            };
          # eche96 = nixosConfigurations.openstick.config.mobile.outputs.android;
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
          let __colemickens_nixcfg_pkgs = rec {
            space-cadet-pinball = prev.callPackage ./pkgs/space-cadet-pinball { };
            space-cadet-pinball-unfree = prev.callPackage ./pkgs/space-cadet-pinball {
              _assets = import ./pkgs/space-cadet-pinball/assets.nix { pkgs = prev; };
            };
            visualizer2 = prev.callPackage ./pkgs/visualizer2 { };
          }; in
          __colemickens_nixcfg_pkgs // { inherit __colemickens_nixcfg_pkgs; });
      };
    in
    (rec {
      inherit nixosConfigsEx nixosConfigs nixosConfigurations toplevels;
      inherit images nixosModules overlays;
    }) // (
      ## SYSTEM-SPECIFIC OUTPUTS ##############################################
      lib.flake-utils.eachSystem [ "x86_64-linux" "aarch64-linux" ] (system:
        let
          pkgs_ = _unfree: import inputs.nixpkgs {
            inherit system;
            overlays = [ overlays.default ];
            config.allowAliases = false;
            config.allowUnfree = _unfree;
          };
          pkgs = pkgs_ false;
          pkgsUnfree = pkgs_ true;
          # internal helpers:
          tfout = import ./cloud { inherit (inputs) terranix; inherit pkgs; };
          mkShell = (name: import ./shells/${name}.nix { inherit inputs pkgs; });
          mkAppScript = (name: script: {
            type = "app";
            program = pkgs.writeScript "${name}.sh" script;
          });
        in
        rec {
          inherit pkgs pkgsUnfree;

          ## DEVSHELLS # some of 'em kinda compose #############################
          devShells = (lib.genAttrs [ "ci" "devenv" "devtools" "gstreamer" "uutils" ] mkShell)
          // { default = devShells.devtools; };

          ## APPS ##############################################################
          apps = {
            tf = { type = "app"; program = tfout.tf.outPath; };
            tf-apply = { type = "app"; program = tfout.apply.outPath; };
            tf-destroy = { type = "app"; program = tfout.destroy.outPath; };
          };

          ## PACKAGES ##########################################################
          packages = (pkgs.__colemickens_nixcfg_pkgs);

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
    );
}
