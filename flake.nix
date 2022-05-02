{
  # flakes feedback
  # - flake-overrides.lock: https://github.com/NixOS/nix/issues/4193
  # - I still dislike the registry + special-cased GitHub special URL syntax
  #  -- bonus validation, gitlab repos are weird because they can be nested
  #  -- forcing users to url-encode '/' in their special flake refs
  # - lots of other stuff, too much to get into...

  description = "colemickens-nixcfg";

  # zfs everywhere
  # networkd+iwd everywhere (wip)
  # nearly identical partition
  # grub (via bootspec) everywhere (wip??)

  inputs = {
    nixlib.url = "github:nix-community/nixpkgs.lib"; #TODO: horrible name! come on!

    nixpkgs.url = "github:colemickens/nixpkgs/cmpkgs"; # for my regular nixpkgs
    cross-armv6l.url = "github:colemickens/nixpkgs/cmpkgs-cross-armv6l";
    cross-riscv64.url = "github:colemickens/nixpkgs/cmpkgs-cross-riscv64";

    # nixos-unstable-small.url = "github:nixos/nixpkgs/nixos-unstable-small";
    # nixos-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # stable.url = "github:nixos/nixpkgs/nixos-22.05"; # for cachix
    riscv64 = { url = "github:zhaofengli/nixos-riscv64"; };

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

    mobile-nixos.url = "github:colemickens/mobile-nixos/2022-03-blueline";
    mobile-nixos.inputs.nixpkgs.follows = "nixpkgs";

    wip-pinebook-pro = { url = "github:colemickens/wip-pinebook-pro/master"; flake = false; };
    # wip-pinebook-pro.inputs.nixpkgs.follows = "nixpkgs"; # ?? # TODO TODO TODO

    nickel = { url = "github:tweag/nickel"; };

    nix-coreboot.url = "github:colemickens/nix-coreboot";
    nix-coreboot.inputs.nixpkgs.follows = "nixpkgs";

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
      # TODO: further cleanup via usage of "nixlib"
      nixlib = inputs.nixlib.outputs.lib;
      supportedSystems = [
        "x86_64-linux"
        "aarch64-linux"
        # "riscv64-none-elf" # TODO
        # "armv6l-linux" # eh, I think time is up
        # "armv7l-linux" # eh, I think time is up
      ];
      forAllSystems = nixlib.genAttrs supportedSystems;
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
        pkgs_ = nixlib.genAttrs (builtins.attrNames inputs) (inp: nixlib.genAttrs supportedSystems (sys: pkgsFor inputs."${inp}" sys [ ]));
        fullPkgs_ = nixlib.genAttrs supportedSystems (sys:
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

      # devshell = can build anything in it
      # shell = just the binaries, I guess
      # app = runnable, but not easy to remote build??
      # legacyPackages = ${pkgs.system} loophole

      devShell = shell;
      devShells = shells;

      shell = forAllSystems (system: shells.${system}.default);
      shells = forAllSystems (system: rec {
        default = (import ./shells/devshell.nix { inherit inputs system minimalMkShell; });
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

          mfb = dev: { type = "app"; program = nixosConfigurations.blueline.config.system.build.mobile-flash-boot.outPath; };
        in
        ({
          # CI (should we use HM for this instead?)
          install-secrets = { type = "app"; program = legacyPackages."${system}".install-secrets.outPath; };

          # Terraform
          tf = { type = "app"; program = tfout.tf.outPath; };
          tf-apply = { type = "app"; program = tfout.apply.outPath; };
          tf-destroy = { type = "app"; program = tfout.destroy.outPath; };
        } // (nixlib.genAttrs [ "blueline" "enchilada" ] mfb))
      );

      colelib = _colelib;

      packages = forAllSystems (s: fullPkgs_.${s}.colePackages);
      pkgs = forAllSystems (s: fullPkgs_.${s});

      overlay = final: prev:
        let p = rec {
          customCommands = prev.callPackage ./pkgs/commands.nix { writePython3Bin = prev.writers.writePython3Bin; };
          customGuiCommands = prev.callPackage ./pkgs/commands-gui.nix { };

          get-xoauth2-token = prev.callPackage ./pkgs/get-xoauth2-token { };
          hodd = prev.callPackage ./pkgs/hodd { };
          keyboard-layouts = prev.callPackage ./pkgs/keyboard-layouts { };
          onionbalance = prev.python3Packages.callPackage ./pkgs/onionbalance { };
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

          # nix-build-uncached = prev.nix-build-uncached.overrideAttrs (old: {
          #   src = prev.fetchFromGitHub {
          #     owner = "colemickens";
          #     repo = "nix-build-uncached";
          #     rev = "36ea105";
          #     sha256 = "sha256-Ovx+q5pdfg+yIF5HU7pV0nR6nnoTa3y/f9m4TV0XXc0=";
          #   };
          # });

          # alacritty/bottom/wezterm - rust updates are ... maybe not working? so...
          #alacritty = prev.callPackage ./pkgs/alacritty {
          #  alacritty = prev.alacritty;
          #};
          # bottom = prev.callPackage ./pkgs/bottom {
          #   bottom = prev.bottom;
          # };
          #wezterm = prev.callPackage ./pkgs/wezterm {
          #  wezterm = prev.wezterm;
          #};
          # unused # headscale = prev.callPackage ./pkgs/headscale { buildGoModule = prev.buildGo117Module; };
          # disabled (we use it from their own flake now)
          #zellij = prev.callPackage ./pkgs/zellij {
          #  zellij = prev.zellij;
          #};
          # disabled (stable is fine) # poweralertd = prev.callPackage ./pkgs/poweralertd { };
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
        linbio = mkSystem inputs.nixpkgs "x86_64-linux" "linbio";
        pelinux = mkSystem inputs.nixpkgs "x86_64-linux" "pelinux";
        slynux = mkSystem inputs.nixpkgs "x86_64-linux" "slynux";
        raisin = mkSystem inputs.nixpkgs "x86_64-linux" "raisin";
        xeep = mkSystem inputs.nixpkgs "x86_64-linux" "xeep";
        netboot-x86_64 = mkSystem inputs.nixpkgs "x86_64-linux" "netboot";
        #######################################################################
        # riscv-linux
        risky = mkSystem inputs.cross-riscv64 "riscv64-linux" "risky";
          # ^^^ realistically since this is a native build, I shouldn't _need_ to use crosspkgs
        #######################################################################
        # aarch64-linux
        netboot-aarch64 = mkSystem inputs.nixpkgs "aarch64-linux" "netboot";
        # retired # pinebook = mkSystem inputs.nixpkgs "aarch64-linux" "pinebook";
        rpifour1 = mkSystem inputs.nixpkgs "aarch64-linux" "rpifour1";
        rpithreebp1 = mkSystem inputs.nixpkgs "aarch64-linux" "rpithreebp1";
        rpizerotwo1 = mkSystem inputs.nixpkgs "aarch64-linux" "rpizerotwo1";
        # rpizerotwo2 = mkSystem inputs.nixpkgs "aarch64-linux" "rpizerotwo2";
        # rpizerotwo3 = mkSystem inputs.nixpkgs "aarch64-linux" "rpizerotwo3";
        sinkor = mkSystem inputs.nixpkgs "aarch64-linux" "sinkor";
        oracular = mkSystem inputs.nixpkgs "aarch64-linux" "oracular";
        pinephone = mkSystem inputs.nixpkgs "aarch64-linux" "pinephone";
        # blueline = mkSystem inputs.nixpkgs "aarch64-linux" "blueline";
        # blueloco    = mkSystem inputs.nixpkgs "x86_64-linux"  "blueloco";
        # enchilada = mkSystem inputs.nixpkgs "aarch64-linux" "enchilada";
        # enchiloco   = mkSystem inputs.nixpkgs "x86_64-linux"  "enchiloco";
        #######################################################################
        # armv6l-linux (cross-built)
        rpizero1 = mkSystem inputs.cross-armv6l "x86_64-linux" "rpizero1";
        rpizero2 = mkSystem inputs.cross-armv6l "x86_64-linux" "rpizero2";
        # disabled:
        # - oracular_kexec  = mkSystem inputs.nixpkgs "aarch64-linux" "oracular/installer"; # not working, half-abandonded
      };
      toplevels = nixlib.genAttrs
        (builtins.attrNames inputs.self.outputs.nixosConfigurations)
        (attr: nixosConfigurations.${attr}.config.system.build.toplevel);


      hydraJobs = forAllSystems (s: {
        #devshell = force_cached s inputs.self.devShell.${s}.inputDerivation;
        shells = force_cached s (builtins.mapAttrs (n: v: v.inputDerivation)
          inputs.self.shells.${s});
        packages = force_cached s (filterPkgs pkgs_.nixpkgs.${s} inputs.self.packages.${s});
        toplevels = force_cached s (builtins.mapAttrs (n: v: v.config.system.build.toplevel)
          (filterHosts pkgs_.nixpkgs.${s} inputs.self.nixosConfigurations));
      });
      # TODO: finish this...
      hydraBundles = forAllSystems (s: (
        pkgs_.nixpkgs.${s}.lib.mapAttrs
          (n: v:
            (pkgs_.nixpkgs.${s}.linkFarmFromDrvs "${n}-bundle"
              (builtins.attrValues v))
          )
          inputs.self.hydraJobs.${s}
      ));

      #hydraAll = forAllSystems (s:
      # TODO: map hydraBundles attributes into a linkFarm
      misc = forAllSystems (s: {
        coreboot_linbio = nixosConfigurations."linbio".config.system.build.coreboot;
      });

      # devices = {
      #   # pinephone = inputs.self.nixosConfigurations.pinephone.config.mobile.outputs.android;
      #   blueline = inputs.self.nixosConfigurations.blueline.config.system.build;
      #   enchilada = inputs.self.nixosConfigurations.enchilada.config.mobile.outputs.android;
      # };
      phones =
        let
          mkPhone = dev: {
            firmware = dev.config.mobile.device.firmware;
            flash-boot = dev.config.system.build.mobile-flash-boot;
          };
          phone_hosts_ = (nixlib.attrNames (nixlib.filterAttrs
            (_: v:
              # v.meta.class = "phone"; // phone,server,desktop,laptop "string-y"?
              v.config.networking.hostName == "blueline" || v.config.networking.hostName == "enchilada"
            )
            nixosConfigurations));
          phone_hosts = nixlib.traceVal phone_hosts_;

          result = (
            (nixlib.genAttrs phone_hosts (h: mkPhone nixosConfigurations."${h}")
            )
            //
            ({
              "blueboot" = (mkPhone (mkSystem inputs.crosspkgs "x86_64-linux" "blueline"));
            })
          );
          result2 = nixlib.traceVal result;
        in
        result2;

      installers =
        let
          installer = pkgs.iso;
        in
        forAllSystems (s: installer);

      towboot =
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
