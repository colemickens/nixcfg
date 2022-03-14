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
    nixos-unstable-git = {
      url = "git+https://github.com/nixos/nixpkgs?ref=nixos-unstable";
    };
    #riscvpkgs = { url = "github:zhaofengli/nixpkgs/riscv-cached"; };
    riscvpkgs = { url = "github:colemickens/nixpkgs/riscv-cached"; };
    riscv64 = { url = "github:zhaofengli/nixos-riscv64"; };

    # crosspkgs.url = "github:colemickens/nixpkgs/crosspkgs";

    home-manager.url = "github:colemickens/home-manager/cmhm";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix/master";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # eep, TODO: do we want to override nixpkgs?
    helix.url = "github:helix-editor/helix";
    jj.url = "github:martinvonz/jj";
    zellij.url = "github:zellij-org/zellij";

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
    impermanence.inputs.nixpkgs.follows = "nixpkgs";

    tow-boot = { url = "github:colemickens/tow-boot/development"; };
    tow-boot.inputs.nixpkgs.follows = "nixpkgs"; # TODO: might break u-boot?

    mobile-nixos.url = "github:colemickens/mobile-nixos/master"; # its nixpkgs is _only_ used for its devshell

    wip-pinebook-pro = { url = "github:colemickens/wip-pinebook-pro/master"; flake = false; };
    # wip-pinebook-pro.inputs.nixpkgs.follows = "nixpkgs"; # ?? # TODO TODO TODO

    nickel = { url = "github:tweag/nickel"; };

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
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        # "riscv64-none-elf" # TODO
        # "armv6l-linux" # eh, I think time is up
        # "armv7l-linux" # eh, I think time is up
      ];
      forAllSystems = genAttrs supportedSystems;
      filterPkg_ = system: (n: p: (builtins.elem "${system}" (p.meta.platforms or [ "x86_64-linux" "aarch64-linux" ])) && !(p.meta.broken or false));
      filterPkgs = pkgs: pkgSet: (pkgs.lib.filterAttrs (filterPkg_ pkgs.system) pkgSet);
      filterHosts = pkgs: cfgs: (pkgs.lib.filterAttrs (n: v: pkgs.system == v.config.nixpkgs.system) cfgs);

      _colelib = rec {
        force_cached = sys: pkgs_.nixpkgs."${sys}".callPackage ./lib/force_cached.nix { };
        minimalMkShell = system: import ./lib/minimalMkShell.nix { pkgs = fullPkgs_.${system}; };
        hydralib = import ./lib/hydralib.nix;
        pkgsFor = pkgs: system: overlays:
          import pkgs {
            inherit system overlays;
            config.allowUnfree = true;
          };
        pkgs_ = genAttrs (builtins.attrNames inputs) (inp: genAttrs supportedSystems (sys: pkgsFor inputs."${inp}" sys [ ]));
        fullPkgs_ = genAttrs supportedSystems (sys:
          pkgsFor inputs.nixpkgs sys [ inputs.self.overlay inputs.nixpkgs-wayland.overlay ]);
        mkSystem = pkgs: system: hostname:
          pkgs.lib.nixosSystem {
            system = system;
            modules = [ (./. + "/hosts/${hostname}/configuration.nix") ];
            specialArgs = { inherit inputs; };
          };
        pkgNames = s: builtins.attrNames (inputs.self.overlay pkgs_.${s} pkgs_.${s});
      };

      _inputs = inputs;

    in
    with _colelib; rec {
      inputs = _inputs;

      devShell = forAllSystems (system: minimalMkShell system {
        name = "nixcfg-devshell";
        nativeBuildInputs = map (x: (x.bin or x.out or x)) (with pkgs_.nixpkgs.${system}; [
          #nixUnstable
          cachix
          nixpkgs-fmt
          nix-prefetch-git
          bash
          curl
          cacert
          jq
          jless
          parallel
          mercurial
          git
          # todo: move a bunch of these to 'apps#update-env' ?
          nettools
          openssh
          ripgrep
          rsync
          sops
          gh
          gawk
          gnused
          gnugrep
          fullPkgs_.${system}.nix-build-uncached
          inputs.nickel.packages.${system}.build
          pkgs.x86_64-linux.OVMF.fd
          # not sure, would be nice for nix stuff to work in helix even if I forget to join the shell
          rnix-lsp
          nixpkgs-fmt
        ]);
      });
      devShells = forAllSystems (system: {
        default = devShell.${system};
        devenv = (import ./shells/devenv.nix { inherit inputs system minimalMkShell; });
        uutils = minimalMkShell system {
          name = "uutils-devshell";
          nativeBuildInputs = with pkgs_.nixpkgs.${system}; [
            (uutils-coreutils.override { prefix = ""; })
          ];
        };
      });

      legacyPackages = forAllSystems (system: {
        # to `nix eval` with the "currentSystem" in certain scenarios
        devShellSrc = inputs.self.devShell.${system}.inputDerivation;
        install-secrets = (import ./.github/secrets.nix { nixpkgs = inputs.nixpkgs; inherit inputs system; });
        bundle = inputs.self.bundles.${system};
      });
      apps = forAllSystems (system:
        let
          app = program: { type = "app"; program = "${program}"; };
          tfout = import ./cloud { terranix = inputs.terranix; pkgs = pkgs_.nixpkgs.${system}; };
        in
        {
          # CI (should we use HM for this instead?)
          install-secrets = { type = "app"; program = legacyPackages."${system}".install-secrets.outPath; };

          # Terraform
          tf = { type = "app"; program = tfout.tf.outPath; };
          tf-apply = { type = "app"; program = tfout.apply.outPath; };
          tf-destroy = { type = "app"; program = tfout.destroy.outPath; };
        });

      colelib = _colelib;

      packages = forAllSystems (s: fullPkgs_.${s}.colePackages);
      pkgs = forAllSystems (s: fullPkgs_.${s});

      overlay = final: prev:
        let p = rec {
          customCommands = prev.callPackage ./pkgs/commands.nix { };
          customGuiCommands = prev.callPackage ./pkgs/commands-gui.nix { };

          #alacritty = prev.callPackage ./pkgs/alacritty {
          #  alacritty = prev.alacritty;
          #};
          bottom = prev.callPackage ./pkgs/bottom {
            bottom = prev.bottom;
          };
          get-xoauth2-token = prev.callPackage ./pkgs/get-xoauth2-token { };
          #glide-player = prev.callPackage ./pkgs/glide-player {
          #};
          headscale = prev.callPackage ./pkgs/headscale {
            buildGoModule = prev.buildGo117Module;
          };
          hodd = prev.callPackage ./pkgs/hodd { };
          keyboard-layouts = prev.callPackage ./pkgs/keyboard-layouts { };
          #nvidia-vaapi-driver = prev.callPackage ./pkgs/nvidia-vaapi-driver {};
          onionbalance = prev.python3Packages.callPackage ./pkgs/onionbalance { };
          poweralertd = prev.callPackage ./pkgs/poweralertd { };
          rumqtt = prev.callPackage ./pkgs/rumqtt { };
          solo2-cli = prev.callPackage ./pkgs/solo2-cli {
            solo2-cli = prev.solo2-cli;
          };
          space-cadet-pinball = prev.callPackage ./pkgs/space-cadet-pinball { };
          space-cadet-pinball-unfree = prev.callPackage ./pkgs/space-cadet-pinball {
            _assets = import ./pkgs/space-cadet-pinball/assets.nix { pkgs = prev; };
          };
          shreddit = prev.python3Packages.callPackage ./pkgs/shreddit { };
          tvp = prev.callPackage ./pkgs/tvp { };
          rtsp-simple-server = prev.callPackage ./pkgs/rtsp-simple-server {
            buildGoModule = prev.buildGo117Module;
          };
          #wezterm = prev.callPackage ./pkgs/wezterm {
          #  wezterm = prev.wezterm;
          #};

          nix-build-uncached = prev.nix-build-uncached.overrideAttrs (old: {
            src = prev.fetchFromGitHub {
              owner = "colemickens";
              repo = "nix-build-uncached";
              rev = "36ea105";
              sha256 = "sha256-Ovx+q5pdfg+yIF5HU7pV0nR6nnoTa3y/f9m4TV0XXc0=";
            };
          });

          # disabled (we use it from their own flake now)
          #zellij = prev.callPackage ./pkgs/zellij {
          #  zellij = prev.zellij;
          #};
          # disabled (dont use) # meli = prev.callPackage ./pkgs/meli {};
          # disabled (very old, prob delete) # bb = prev.callPackage ./pkgs/bb {};
          # disabled (huge build + unused) # cchat-gtk = prev.callPackage ./pkgs/cchat-gtk {};
          # disabled (not sure how to add rocksdb) # conduit = prev.callPackage ./pkgs/conduit {};
          # disabled (very old, prob delete) # drm-howto = prev.callPackage ./pkgs/drm-howto {};
          # disabled # mirage-im = prev.libsForQt5.callPackage ./pkgs/mirage-im {};
          # disabled # neochat = prev.libsForQt5.callPackage ./pkgs/neochat { neochat = prev.neochat; };
          # disabled # just use usbip/usbredir # rkvm = prev.callPackage ./pkgs/rkvm {};
          # disabled: they don't want me to build anvil # smithay = prev.callPackage ./pkgs/smithay {};
        }; in p // { colePackages = p; };

      # nixosModules = {
      #   hydra-auto = import ./modules/hydra-auto.nix;
      #   otg = import ./modules/otg.nix;
      #   other-arch-vm = import ./modules/other-arch-vm.nix;
      # };

      nixosConfigurations = {
        #######################################################################
        # x86_64-linux
        jeffhyper = mkSystem inputs.nixpkgs "x86_64-linux" "jeffhyper";
        porty = mkSystem inputs.nixpkgs "x86_64-linux" "porty";
        raisin = mkSystem inputs.nixpkgs "x86_64-linux" "raisin";
        xeep = mkSystem inputs.nixpkgs "x86_64-linux" "xeep";
        netboot-x86_64 = mkSystem inputs.nixpkgs "x86_64-linux" "netboot";
        #######################################################################
        # riscv-linux
        risky = mkSystem inputs.riscvpkgs "riscv64-linux" "risky";
        #######################################################################
        # aarch64-linux
        netboot-aarch64 = mkSystem inputs.nixpkgs "aarch64-linux" "netboot";
        pinebook = mkSystem inputs.nixpkgs "aarch64-linux" "pinebook";
        rpifour1 = mkSystem inputs.nixpkgs "aarch64-linux" "rpifour1";
        rpithreebp1 = mkSystem inputs.nixpkgs "aarch64-linux" "rpithreebp1";
        rpizerotwo1 = mkSystem inputs.nixpkgs "aarch64-linux" "rpizerotwo1";
        # rpizerotwo2 = mkSystem inputs.nixpkgs "aarch64-linux" "rpizerotwo2";
        # rpizerotwo3 = mkSystem inputs.nixpkgs "aarch64-linux" "rpizerotwo3";
        sinkor = mkSystem inputs.nixpkgs "aarch64-linux" "sinkor";
        oracular = mkSystem inputs.nixpkgs "aarch64-linux" "oracular";
        # pinephone   = mkSystem inputs.nixpkgs "aarch64-linux" "pinephone";
        # blueline    = mkSystem inputs.nixpkgs "aarch64-linux" "blueline";
        # blueloco    = mkSystem inputs.nixpkgs "x86_64-linux"  "blueloco";
        # enchilada   = mkSystem inputs.nixpkgs "aarch64-linux" "enchilada";
        # enchiloco   = mkSystem inputs.nixpkgs "x86_64-linux"  "enchiloco";
        #######################################################################
        # armv6l-linux (cross-built)
        # rpizero1 = mkSystem inputs.crosspkgs "x86_64-linux" "rpizero1";
        # rpizero2 = mkSystem inputs.crosspkgs "x86_64-linux" "rpizero2";
        # disabled:
        # - oracular_kexec  = mkSystem inputs.nixpkgs "aarch64-linux" "oracular/installer"; # not working, half-abandonded
      };
      toplevels = genAttrs
        (builtins.attrNames inputs.self.outputs.nixosConfigurations)
        (attr: nixosConfigurations.${attr}.config.system.build.toplevel);


      hydraJobs = forAllSystems (s: {
        #devshell = force_cached s inputs.self.devShell.${s}.inputDerivation;
        devShells = force_cached s (builtins.mapAttrs (n: v: v.inputDerivation)
          inputs.self.devShells.${s});
        packages = force_cached s (filterPkgs pkgs_.nixpkgs.${s} inputs.self.packages.${s});
        toplevels = force_cached s (builtins.mapAttrs (n: v: v.config.system.build.toplevel)
          (filterHosts pkgs_.nixpkgs.${s} inputs.self.nixosConfigurations));
      });
      # TODO: finish this...
      hydraBundles = forAllSystems (s: (
        pkgs_.nixpkgs.${s}.lib.mapAttrs
          (n: v:
            (pkgs_.nixpkgs.${s}.linkFarmFromDrvs "${n}-bundle"
              (builtins.trace
                (builtins.mapAttrs (n: v: v.meta.name) v)
                (builtins.attrValues v)))
          )
          inputs.self.hydraJobs.${s}
      ));
      #hydraAll = forAllSystems (s:
      # TODO: map hydraBundles attributes into a linkFarm


      devices = {
        pinephone = inputs.self.nixosConfigurations.pinephone.config.mobile.outputs.android;
        blueline = inputs.self.nixosConfigurations.blueline.config.mobile.outputs.android;
        enchilada = inputs.self.nixosConfigurations.enchilada.config.mobile.outputs.android;
      };
      images =
        let
          #tb_aarch64 = import inputs.tow-boot { pkgs = import inputs.nixpkgs { system = "aarch64-linux"; }; };
          towboot_aarch64 = inputs.tow-boot.packages.aarch64-linux;
          #towboot_rpi_combined = TODO;
        in
        rec {
          #
          # TOW-BOOT IMAGES
          # (todo: consider if we need separate tow-boot images for the rpizero* devices)
          rpizero1_towboot = towboot_armv6l.raspberryPi;

          rpifour1_towboot = towboot_aarch64.raspberryPi-aarch64;
          sinkor_towboot = towboot_aarch64.raspberryPi-aarch64;

          pinebook_towboot = towboot_aarch64.pine64-pinebookPro;

          rpizerotwo1_towboot = towboot_aarch64.raspberryPi-aarch64;
          rpizerotwo2_towboot = towboot_aarch64.raspberryPi-aarch64;
          rpizerotwo3_towboot = towboot_aarch64.raspberryPi-aarch64;

          # TODO: replace these with images that use a tow-boot builder to build
          # a normal in-place-updatable nixos
          # rpizero1  = inputs.self.nixosConfigurations.rpizero1.config.system.build.sdImage;
          # rpizero2  = inputs.self.nixosConfigurations.rpizero2.config.system.build.sdImage;
          # rpionebp  = inputs.self.nixosConfigurations.rpionebp.config.system.build.sdImage;

          #
          # MOBILE-NIXOS IMAGES
          blueline = let x = inputs.self.nixosConfigurations.blueline.config.system.build.mobile-nixos; in
            pkgs_.nixpkgs.aarch64-linux.linkFarmFromDrvs "blueline-bundle" ([
              # ? # devices.blueline.extra
              # ? # devices.blueline.android-fastboot-images
              x.scripts.nixosBoot
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
