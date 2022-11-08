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

  ## NIX_CONFIG ###############################################################
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
      flake-utils = inputs.nixlib.lib.flake-utils;
      systems = [ "x86_64-linux" "aarch64-linux" "riscv64-linux" ];

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
          rpifour1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          rpithreebp1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          rpizerotwo1 = { pkgs = inputs.nixpkgs; sys = "aarch64-linux"; };
          openstick = { pkgs = inputs.nixpkgs; sys = "x86_64-linux"; };
          visionfiveone1 = { pkgs = inputs.nixpkgs; sys = "riscv64-linux"; };
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
          openstick = {
            inherit ((cfg "openstick").mobile.outputs.android)
              android-flashable-system android-flashable-bootimg
              android-abootimg android-bootimg;
          };
          # eche96 = nixosConfigurations.openstick.config.mobile.outputs.android;
        };

      ## NIXOS_MODULES # TODO: we don't use these? #############################
      nixosModules = {
        loginctl-linger = import ./modules/loginctl-linger.nix;
        ttys = import ./modules/ttys.nix;
        other-arch-vm = import ./modules/other-arch-vm.nix;
        webrtcsink = import ./modules/webrtcsink.nix;
      };

      ## OVERLAY ################################################################
      overlays = {
        default = (final: prev:
          # TODO: must be a better way?
          let __colemickens_nixcfg_pkgs = rec {
            test = prev.hello;
          }; in
          __colemickens_nixcfg_pkgs // { inherit __colemickens_nixcfg_pkgs; });
      };
    in
    (rec {
      inherit nixosConfigsEx nixosConfigs nixosConfigurations;
      inherit images nixosModules overlays;
    }) // (
      ## SYSTEM-SPECIFIC OUTPUTS ##############################################
      lib.flake-utils.eachSystem systems (system:
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
