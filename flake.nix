{
  # flakes feedback
  # - flake-overrides.lock: https://github.com/NixOS/nix/issues/4193
  # - I still dislike the registry + special-cased GitHub special URL syntax
  #  -- bonus validation, gitlab repos are weird because they can be nested
  #  -- forcing users to url-encode '/' in their special flake refs
  # - lots of other stuff, too much to get into...

  description = "colemickens-nixcfg";

  inputs = {
    nixpkgs.url = "github:colemickens/nixpkgs/cmpkgs"; # for my regular nixpkgs
    nixos-unstable-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    stable.url = "github:nixos/nixpkgs/nixos-21.05"; # for cachix

    crosspkgs.url = "github:colemickens/nixpkgs/crosspkgs";

    home-manager.url = "github:colemickens/home-manager/cmhm";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix/master";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    hardware.url = "github:nixos/nixos-hardware";

    nixpkgs-wayland.url = "github:nix-community/nixpkgs-wayland/master";
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";

    firefox.url = "github:colemickens/flake-firefox-nightly";
    firefox.inputs.nixpkgs.follows = "nixpkgs";

    impermanence.url = "github:nix-community/impermanence/5e8913aa1c311da17e3da5a4bf5c5a47152f6408"; # TODO TODO TODO TODO TODO
    impermanence.inputs.nixpkgs.follows = "nixpkgs";

    tow-boot = { url = "github:colemickens/tow-boot"; };
    tow-boot.inputs.nixpkgs.follows = "nixpkgs"; # TODO: might break u-boot?

    mobile-nixos.url = "github:colemickens/mobile-nixos/master"; # its nixpkgs is _only_ used for its devshell

    wip-pinebook-pro = { url = "github:colemickens/wip-pinebook-pro/master"; flake = false; };
    # wip-pinebook-pro.inputs.nixpkgs.follows = "nixpkgs"; # ?? # TODO TODO TODO

    terranix.url = "github:terranix/terranix";
    terranix.inputs.nixpkgs.follows = "nixpkgs";

    # used for... veloren? other nightly shit? what?
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

  outputs = inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "armv6l-linux" "armv7l-linux" ];
      forAllSystems = genAttrs supportedSystems;
      filterPkg_ = system: (n: p: (builtins.elem "${system}" (p.meta.platforms or [ "x86_64-linux" "aarch64-linux" ])) && !(p.meta.broken or false));
      filterPkgs = pkgs: pkgSet: (pkgs.lib.filterAttrs (filterPkg_ pkgs.system) pkgSet);
      filterHosts = pkgs: cfgs: (pkgs.lib.filterAttrs (n: v: pkgs.system == v.config.nixpkgs.system) cfgs);
      pkgsFor = pkgs: system: overlays:
        import pkgs {
          inherit system overlays;
          config.allowUnfree = true;
        };
      pkgs_ = genAttrs (builtins.attrNames inputs) (inp: genAttrs supportedSystems (sys: pkgsFor inputs."${inp}" sys []));
      fullPkgs_ = genAttrs supportedSystems (sys:
        pkgsFor inputs.nixpkgs sys [ inputs.self.overlay inputs.nixpkgs-wayland.overlay ]);
      mkSystem = pkgs: system: hostname:
        pkgs.lib.nixosSystem {
          system = system;
          modules = [(./. + "/hosts/${hostname}/configuration.nix")];
          specialArgs = { inherit inputs; };
        };

      minimalMkShell = system: import ./lib/minimalMkShell.nix { pkgs = fullPkgs_.${system}; };
      hydralib = import ./lib/hydralib.nix;

      force_cached = sys: pkgs_.nixpkgs."${sys}".callPackage ./lib/force_cached.nix {};
      pkgNames = s: builtins.attrNames (inputs.self.overlay pkgs_.${s} pkgs_.${s});
    in rec {
      devShell = forAllSystems (system: minimalMkShell system {
        name = "nixcfg-devshell";
        nativeBuildInputs = map (x: (x.bin or x.out or x)) (with pkgs_.nixpkgs.${system}; [
          nixUnstable cachix nixpkgs-fmt nix-prefetch-git
          bash curl cacert jq parallel mercurial git tailscale
          nettools openssh ripgrep rsync sops gh gawk gnused gnugrep
          # nix-build-uncached # use the overlayed one for now
          #fullPkgs_.${system}.metal-cli
          fullPkgs_.${system}.nix-build-uncached
        ]);
      });
      devShells = forAllSystems (system: {
        devenv = (import ./shells/shell-devenv.nix { inherit inputs system minimalMkShell; });
        legacy = (import ./shells/shell-legacy.nix { inherit inputs system minimalMkShell; });
      });

      legacyPackages = forAllSystems (system: { # to `nix eval` with the "currentSystem" in certain scenarios
        devShellSrc = inputs.self.devShell.${system}.inputDerivation;
        install-secrets = (import ./.github/secrets.nix { nixpkgs = inputs.nixpkgs; inherit inputs system; });
        bundle = inputs.self.bundles.${system};
      });
      apps = forAllSystems (system: let
        app = program: { type = "app"; program = "${program}"; };
        tfout = import ./cloud { terranix = inputs.terranix; pkgs = pkgs_.nixpkgs.${system}; };
      in {
        # CI (should we use HM for this instead?)
        install-secrets = { type = "app"; program = legacyPackages."${system}".install-secrets.outPath; };

        # Terraform
        tf = { type = "app"; program = tfout.tf.outPath; };
        tf-apply = { type = "app"; program = tfout.apply.outPath; };
        tf-destroy = { type = "app"; program = tfout.destroy.outPath; };
      });

      packages = forAllSystems (s: fullPkgs_.${s}.colePackages);
      pkgs = forAllSystems (s: fullPkgs_.${s});

      overlay = final: prev:
        let p = rec {
          customCommands = prev.callPackage ./pkgs/commands.nix {};
          customGuiCommands = prev.callPackage ./pkgs/commands-gui.nix {};

          bb = prev.callPackage ./pkgs/bb {};
          cchat-gtk = prev.callPackage ./pkgs/cchat-gtk {};
          conduit = prev.callPackage ./pkgs/conduit {};
          drm-howto = prev.callPackage ./pkgs/drm-howto {};
          get-xoauth2-token = prev.callPackage ./pkgs/get-xoauth2-token {};
          headscale = prev.callPackage ./pkgs/headscale {};
          jj = prev.callPackage ./pkgs/jj {
            rustPlatform = (prev.makeRustPlatform {
              inherit (inputs.fenix.packages.${prev.system}.minimal) cargo rustc;
            });
          };
          keyboard-layouts = prev.callPackage ./pkgs/keyboard-layouts {};
          mirage-im = prev.libsForQt5.callPackage ./pkgs/mirage-im {};
          meli = prev.callPackage ./pkgs/meli {};
          neochat = prev.libsForQt5.callPackage ./pkgs/neochat { neochat = prev.neochat; };
          poweralertd = prev.callPackage ./pkgs/poweralertd {};
          rkvm = prev.callPackage ./pkgs/rkvm {};
          shreddit = prev.python3Packages.callPackage ./pkgs/shreddit {};
          rtsp-simple-server = prev.callPackage ./pkgs/rtsp-simple-server {};
          wezterm = prev.callPackage ./pkgs/wezterm { wezterm = prev.wezterm; };
          zellij = prev.callPackage ./pkgs/zellij { zellij = prev.zellij; };

          nix-build-uncached = prev.nix-build-uncached.overrideAttrs(old: {
            src = prev.fetchFromGitHub {
              owner = "colemickens";
              repo = "nix-build-uncached";
              rev = "36ea105"; sha256 = "sha256-Ovx+q5pdfg+yIF5HU7pV0nR6nnoTa3y/f9m4TV0XXc0=";
            };
          });
        }; in p // { colePackages = p; };

      # nixosModules = {
      #   hydra-auto = import ./modules/hydra-auto.nix;
      #   otg = import ./modules/otg.nix;
      #   other-arch-vm = import ./modules/other-arch-vm.nix;
      # };

      nixosConfigurations = {
        # x86_64-linux
        jeffhyper = mkSystem inputs.nixpkgs "x86_64-linux"  "jeffhyper";
        porty     = mkSystem inputs.nixpkgs "x86_64-linux"  "porty";
        raisin    = mkSystem inputs.nixpkgs "x86_64-linux"  "raisin";
        xeep      = mkSystem inputs.nixpkgs "x86_64-linux"  "xeep";
        # aarch64-linux
        pinebook    = mkSystem inputs.nixpkgs "aarch64-linux" "pinebook";
        pinephone   = mkSystem inputs.nixpkgs "aarch64-linux" "pinephone";
        blueline    = mkSystem inputs.nixpkgs "aarch64-linux" "blueline";
        #blueloco    = mkSystem inputs.nixpkgs "x86_64-linux"  "blueloco";
        enchilada   = mkSystem inputs.nixpkgs "aarch64-linux" "enchilada";
        #enchiloco   = mkSystem inputs.nixpkgs "x86_64-linux"  "enchiloco";
        rpifour1    = mkSystem inputs.nixpkgs "aarch64-linux" "rpifour1";
        rpizerotwo1 = mkSystem inputs.nixpkgs "aarch64-linux" "rpizerotwo1";
        # rpizerotwo2 = mkSystem inputs.nixpkgs "aarch64-linux" "rpizerotwo2";
        # rpizerotwo3 = mkSystem inputs.nixpkgs "aarch64-linux" "rpizerotwo3";
        sinkor      = mkSystem inputs.nixpkgs "aarch64-linux" "sinkor";
        oracular    = mkSystem inputs.nixpkgs "aarch64-linux" "oracular";
        # armv6l-linux (cross-built)
        rpizero1 = mkSystem inputs.crosspkgs "x86_64-linux" "rpizero1";
        rpizero2 = mkSystem inputs.crosspkgs "x86_64-linux" "rpizero2";
        # disabled:
        # - oracular_kexec  = mkSystem inputs.nixpkgs "aarch64-linux" "oracular/installer"; # not working, half-abandonded
      };
      toplevels = genAttrs
        (builtins.attrNames inputs.self.outputs.nixosConfigurations)
        (attr: nixosConfigurations.${attr}.config.system.build.toplevel);
      topbundles = forAllSystems (s:
        pkgs_.nixpkgs."${s}".linkFarmFromDrvs "${s}-toplevel-bundle" ([]
          ++ (builtins.attrValues hydraJobs.${s}.hosts))
      );
      # hydraSpecs =
      #   let
      #     nfj = b: hydralib.flakeJob "github:colemickens/nixcfg/${b}";
      #   in {
      #     jobsets = hydralib.makeSpec {
      #       nixcfg-main        = nfj "main";
      #       nixcfg-auto-update = nfj "auto-update";
      #     };
      #   };

      hydraJobs = forAllSystems (s: {
        devshell = force_cached s inputs.self.devShell.${s}.inputDerivation;
        pkgs = force_cached s (filterPkgs pkgs_.nixpkgs.${s} inputs.self.packages.${s});
        hosts = force_cached s (builtins.mapAttrs (n: v: v.config.system.build.toplevel)
          (filterHosts pkgs_.nixpkgs.${s} inputs.self.nixosConfigurations));
      });
      bundles = forAllSystems (s:
        pkgs_.nixpkgs."${s}".linkFarmFromDrvs "${s}-bundle" ([]
          ++ [ inputs.self.devShell.${s}.inputDerivation ]
          ++ (builtins.attrValues hydraJobs.${s}.pkgs)
          ++ (builtins.attrValues hydraJobs.${s}.hosts)
        ));

      devices = {
        blueline = inputs.self.nixosConfigurations.blueline.config.mobile.outputs.android;
        enchilada = inputs.self.nixosConfigurations.enchilada.config.mobile.outputs.android;
      };

      images = let
        #tb_aarch64 = import inputs.tow-boot { pkgs = import inputs.nixpkgs { system = "aarch64-linux"; }; };
        tb_aarch64 = inputs.tow-boot.packages.aarch64-linux;
      in {
        # TODO: move rpifour1 back to nixos + tow-boot (and then drop old rpi4 nixpkgs commits + pr)
        #rpifour1_towboot = tb_aarch64.raspberryPi4.sharedImage; # not used yet, still on weird cmpkgs rpi4 stuff
        sinkor_towboot = tb_aarch64.raspberryPi4-aarch64; # sharedImage? wtf? where did taht come from?
        pinebook_towboot = tb_aarch64.pine64-pinebookPro;
        rpizerotwo1_towboot = tb_aarch64.raspberryPi-aarch64;
        # rpizerotwo2_towboot = tb_aarch64.raspberryPi-aarch64;
        # rpizerotwo3_towboot = tb_aarch64.raspberryPi-aarch64;

        rpizero1  = inputs.self.nixosConfigurations.rpizero1.config.system.build.sdImage;
        rpizero2  = inputs.self.nixosConfigurations.rpizero2.config.system.build.sdImage;
        rpionebp  = inputs.self.nixosConfigurations.rpionebp.config.system.build.sdImage;

        blueline = let x = inputs.self.nixosConfigurations.blueline.config.system.build.mobile-nixos; in
          pkgs_.nixpkgs.aarch64-linux.linkFarmFromDrvs "blueline-bundle" ([
            # ? # devices.blueline.extra
            # ? # devices.blueline.android-fastboot-images
            x.scripts.nixos
            x.scripts.factoryReset
            #devices.blueline.android-flashable-bootimg
            #devices.blueline.android-flashable-system
          ]);
        enchilada = let x = inputs.self.nixosConfigurations.enchilada.config.system.build.mobile-nixos; in
          pkgs_.nixpkgs.aarch64-linux.linkFarmFromDrvs "enchilada-bundle" ([
            # valid: # (zstd, device-specific flashing script for PC)
            #x.scripts.nixos
            x.scripts.nixosBoot
            #x.scripts.nixosSystem
            #x.scripts.factoryReset

            # valid: # (slow, uses zip, no script for PC)
            #devices.enchilada.android-flashable-bootimg
            #devices.enchilada.android-flashable-system
          ]);
      };

      # linuxVMs = {
      #   demovm = inputs.self.nixosConfigurations.demovm.config.system.build.vm;
      #   testipfsvm = inputs.self.nixosConfigurations.testipfsvm.config.system.build.vm;
      # };
      # winVMs = {
      #   nixwinvm = import ./hosts/nixwinvm {
      #     pkgs = pkgs_.nixpkgs.x86_64-linux;
      #     inherit inputs;
      #   };
      # };

      # experiments = {
      #   nixbox = {
      #     dash = import ./hosts/nixbox/dashboard.nix { inherit inputs; };
      #     linux = import ./hosts/nixbox/linux.nix { inherit inputs; };
      #   };
      # };
    };
}
