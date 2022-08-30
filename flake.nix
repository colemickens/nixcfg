{
  # flakes feedback
  # - flake-overrides.lock: https://github.com/NixOS/nix/issues/4193
  # - I still dislike the registry + special-cased GitHub special URL syntax
  #  -- bonus validation, gitlab repos are weird because they can be nested
  #  -- forcing users to url-encode '/' in their special flake refs
  # - lots of other stuff, too much to get into...
  # - FLAKE_LOCK idea
  # - how do options propagate to remote builders?
  # - remote building in general is a bit weird

  description = "colemickens-nixcfg";

  # zfs everywhere
  # networkd+iwd everywhere (wip)
  # nearly identical partition
  # grub (via bootspec) everywhere (wip??)

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

    tow-boot-rpi = {
      url = "github:colemickens/Tow-Boot/rpi";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.rpipkgs.follows = "rpipkgs";
    };
    tow-boot-radxa-zero = {
      url = "github:colemickens/Tow-Boot/radxa-zero";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    tow-boot-visionfive = {
      url = "github:colemickens/Tow-Boot/visionfive";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mobile-nixos.url = "github:colemickens/mobile-nixos/2022-03-blueline";
    mobile-nixos.inputs.nixpkgs.follows = "nixpkgs";

    mobile-nixos-openstick.url = "github:colemickens/mobile-nixos/openstick";
    mobile-nixos-openstick.inputs.nixpkgs.follows = "nixpkgs";

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
        gstreamer = (import ./shells/gstreamer.nix { inherit inputs system minimalMkShell; });
        uutils = minimalMkShell system {
          name = "uutils-devshell";
          nativeBuildInputs = with pkgs_.nixpkgs.${system}; [
            (uutils-coreutils.override { prefix = ""; })
          ];
        };
      });

      legacyPackages = forAllSystems (s: {
        # to `nix eval` with the "currentSystem" in certain scenarios
        devShellSrc = inputs.self.devShell.${s}.inputDerivation;
        install-secrets = (import ./.github/secrets.nix { nixpkgs = inputs.nixpkgs; inherit inputs; system = s; });
        bundle = inputs.self.bundles.${s};
        cachable = pkgs_.nixpkgs.${s}.linkFarmFromDrvs "cachable-${s}" [
          inputs.self.devShell.${s}.inputDerivation
          inputs.self.devShells.${s}.devenv.inputDerivation
          inputs.self.devShells.${s}.gstreamer.inputDerivation
        ];
      });
      apps = forAllSystems (system:
        let
          app = program: { type = "app"; program = "${program}"; };
          tfout = import ./cloud { terranix = inputs.terranix; pkgs = pkgs_.nixpkgs.${system}; };

          mfb = dev: { type = "app"; program = nixosConfigurations.blueline.config.system.build.mobile-flash-boot.outPath; };
          ds = dev: { type = "app"; program = nixosConfigurations.${dev}.config.system.build.deployScript; };
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
          // (nixlib.genAttrs [ "blueline" "enchilada" ] mfb)
          // (nixlib.genAttrs [ "rpithreebp1" ] ds)
        )

      );

      colelib = _colelib;

      packages = forAllSystems (s: fullPkgs_.${s}.colePackages);
      pkgs = forAllSystems (s: fullPkgs_.${s});

      overlay = final: prev:
        let p = rec {
          customCommands = prev.callPackage ./pkgs/commands.nix { writePython3Bin = prev.writers.writePython3Bin; };
          customGuiCommands = prev.callPackage ./pkgs/commands-gui.nix { };

          anodium = prev.callPackage ./pkgs/anodium { };
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
          rsntp = prev.callPackage ./pkgs/rsntp { };
          # rtsp-simple-server = prev.callPackage ./pkgs/rtsp-simple-server {
          #   buildGoModule = prev.buildGo117Module;
          # };
          visualizer2 = prev.callPackage ./pkgs/visualizer2 { };

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

      # TODO:
      # - for now we just re-use the nixosConfiguration
      # - but maybe, for example, we want to cross-compile these since hosted from 'xeep'
      xnetboots = {};
      netboots = nixlib.genAttrs
        [
          "risky-cross"
          "rpifour1"
          "rpithreebp1"
          # "radxazero1"
          # "rpizerotwo1"
          # "rpizerotwo2"
        ]
        (h: nixosConfigurations.${h}.config.system.build.extras.nfsboot);
      # nfsfirms = nixlib.genAttrs
      #   [
      #     "rpifour1"
      #     "rpizerotwo1"
      #     "rpizerotwo2"
      #     "rpithreebp1"
      #     "risky-cross"
      #   ]
      #   (h: nixosConfigurations.${h}.config.system.build.extras.nfsfirm);

      netbootsCross =
        let
          crossModule1 = crossSystem: ({ config, lib, ... }: {
            nixpkgs.localSystem = { system = "x86_64-linux"; };
            nixpkgs.crossSystem = crossSystem;
          });
          crossNfsboot = h:
            (crossSystems h _system).config.system.build.extras.nfsboot;

          crossModule2 = crossSystem: ({ config, lib, ... }: {
            # nixpkgs.localSystem = { system = "x86_64-linux"; };
            nixpkgs.crossSystem = crossSystem;
          });
          makeNfsbootCross = h: crossSystem:
            (nixosConfigurations.${h}.extendModules {
              modules = [ (crossModule1 crossSystem) ];
            }).config.system.build.extras.nfsboot;
          makeNfsbootCross2 = h: crossSystem:
            (mkSystem_ inputs.rpipkgs "x86_64-linux" h [ (crossModule2 crossSystem) ]).config.system.build.extras.nfsboot;
        in
        {
          rpifour1a = makeNfsbootCross "rpifour1" { system = "aarch64-linux"; };
          rpifour1b = makeNfsbootCross "rpifour1" { system = "aarch64-linux"; };
          rpifour2 = makeNfsbootCross2 "rpifour2" { system = "aarch64-linux"; };
          rpithreebp1 = makeNfsbootCross "rpithreebp1" { system = "aarch64-linux"; };
        };

      nixosConfigurations = {
        #######################################################################
        # x86_64-linux
        carbon = mkSystem inputs.nixpkgs "x86_64-linux" "carbon";
        jeffhyper = mkSystem inputs.nixpkgs "x86_64-linux" "jeffhyper";
        slynux = mkSystem inputs.nixpkgs "x86_64-linux" "slynux";
        raisin = mkSystem inputs.nixpkgs "x86_64-linux" "raisin";
        xeep = mkSystem inputs.nixpkgs "x86_64-linux" "xeep";
        # netboot-x86_64 = mkSystem inputs.nixpkgs "x86_64-linux" "netboot";
        #######################################################################
        # riscv-linux
        risky = mkSystem inputs.cross-riscv64 "riscv64-linux" "risky";
        risky-cross = mkSystem inputs.cross-riscv64 "x86_64-linux" "risky-cross";
        # ^^^ realistically since this is a native build, I shouldn't _need_ to use crosspkgs
        #######################################################################
        # aarch64-linux
        radxazero1 = mkSystem inputs.rpipkgs "aarch64-linux" "radxazero1";
        rpifour1 = mkSystem inputs.rpipkgs "aarch64-linux" "rpifour1";
        # rpifour2 = mkSystem inputs.rpipkgs "aarch64-linux" "rpifour2";
        rpithreebp1 = mkSystem inputs.rpipkgs "aarch64-linux" "rpithreebp1";
        rpizerotwo1 = mkSystem inputs.rpipkgs "aarch64-linux" "rpizerotwo1";
        rpizerotwo2 = mkSystem inputs.rpipkgs "aarch64-linux" "rpizerotwo2";
        # rpizerotwo3 = mkSystem inputs.rpipkgs "aarch64-linux" "rpizerotwo3";
        ## oracular = mkSystem inputs.nixpkgs "aarch64-linux" "oracular";
        pinephone = mkSystem inputs.nixpkgs "aarch64-linux" "pinephone";
        # blueline = mkSystem inputs.nixpkgs "aarch64-linux" "blueline";
        # blueloco    = mkSystem inputs.nixpkgs "x86_64-linux"  "blueloco";
        # enchilada = mkSystem inputs.nixpkgs "aarch64-linux" "enchilada";
        # enchiloco   = mkSystem inputs.nixpkgs "x86_64-linux"  "enchiloco";
        openstick = mkSystem inputs.nixpkgs "aarch64-linux" "openstick";
        #######################################################################
        # armv6l-linux (cross-built)
        # rpizero1 = mkSystem inputs.cross-armv6l "x86_64-linux" "rpizero1";
        # rpizero2 = mkSystem inputs.cross-armv6l "x86_64-linux" "rpizero2";
        # disabled:
        # - oracular_kexec  = mkSystem inputs.nixpkgs "aarch64-linux" "oracular/installer"; # not working, half-abandonded
        #######################################################################
        # installer (x86_64-linux for now)
        installer = mkSystem inputs.nixpkgs "x86_64-linux" "installer";
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
        netboots = force_cached s (filterPkgsTgt pkgs_.nixpkgs.${s} netboots);
        nfsfirms = force_cached s (filterPkgs pkgs_.nixpkgs.${s} nfsfirms);
        netpayload = force_cached s (
          (filterPkgs pkgs_.nixpkgs.${s} netboots) // (filterPkgs pkgs_.nixpkgs.${s} nfsfirms)
        );
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
      # misc = forAllSystems (s: {
      #   coreboot_linbio = nixosConfigurations."linbio".config.system.build.coreboot;
      # });

      # devices = {
      #   # pinephone = inputs.self.nixosConfigurations.pinephone.config.mobile.outputs.android;
      #   blueline = inputs.self.nixosConfigurations.blueline.config.system.build;
      #   enchilada = inputs.self.nixosConfigurations.enchilada.config.mobile.outputs.android;
      # };
      images = {
        openstick = nixosConfigurations.openstick.config.mobile.outputs.android.abootimg;
      };
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

      # TODO:
      # - use bootspec to compose a multi-arch image
      # - that can be 'dd'd or synced frm any-arch machine  
      # installer =
      #   let
      #     installer = pkgs.iso;
      #   in
      #   forAllSystems (s: installer);
      # - bundle the installer script
      # - the installer script should also manage host ssh/age keys + secrets re-provisioning
      
      installer = nixosConfigurations.installer.config.system.build.isoImage;

      # images = nixlib.genAttrs [ "rpizero1" "rpizero2" ] (h:
      #   nixosConfigurations.${h}.config.system.build.sdImage);

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
