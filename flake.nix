{
  # flakes feedback
  # - flake-overrides.nix: https://github.com/NixOS/nix/issues/4193
  # - I dislike the special-cased GitHub special URL syntax
  # shout-outs to: @bqv, @balsoft, @cole-h for flake.nix inspriation

  description = "colemickens-nixcfg";

  inputs = {
    nixpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; }; # for my regular nixpkgs
    nixos-unstable-small = { url = "github:nixos/nixpkgs/nixos-unstable-small"; };
    nixos-unstable = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    stable = { url = "github:nixos/nixpkgs/nixos-21.05"; }; # for cachix

    crosspkgs = {
      # LKG: 79c444b5bdeaba142d128afddee14c89ecf2a968
      url = "github:colemickens/nixpkgs/crosspkgs";
    };

    # We're back to using nixUnstable so we shouldn't need this:
    nix.url = "github:nixos/nix/master";

    impermanence.url = "github:nix-community/impermanence/5e8913aa1c311da17e3da5a4bf5c5a47152f6408";
    impermanence.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-kubernetes.url = "github:colemickens/nixpkgs-kubernetes/main";
    nixpkgs-kubernetes.inputs.nixpkgs.follows = "nixpkgs";

    niche.url = "github:colemickens/niche/master";
    niche.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:colemickens/home-manager/cmhm";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    construct.url = "github:matrix-construct/construct";
    construct.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix/master";
    #sops-nix.url = "github:colemickens/sops-nix/master";
    #sops-nix.url = "github:mic92/sops-nix/23fae8a8b15b07c11f8c4c7f95ae0ce191d0c86a";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:colemickens/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    firefox  = { url = "github:colemickens/flake-firefox-nightly"; };
    firefox.inputs.nixpkgs.follows = "nixpkgs";

    # chromium  = { url = "github:colemickens/flake-chromium"; };
    # chromium.inputs.nixpkgs.follows = "nixpkgs";

    #nixos-veloren = { url = "github:colemickens/nixos-veloren"; };
    #nixos-veloren.inputs.nixpkgs.follows = "nixpkgs";

    mobile-nixos = { url = "github:colemickens/mobile-nixos/master"; flake = false; };
    #mobile-nixos = { url = "github:colemickens/mobile-nixos/mobile-nixos-blueline"; };
    # wait is the flakes pr not merged ? :(
    # mobile-nixos = { url = "github:samueldr/mobile-nixos/mobile-nixos-blueline"; };
    #mobile-nixos.inputs.nixpkgs.follows = "nixpkgs";

    # nix-ipfs = { url = "github:obsidiansystems/nix"; };

    nixos-azure = { url = "github:colemickens/nixos-azure/dev"; };
    nixos-azure.inputs.nixpkgs.follows = "nixpkgs";

    wip-pinebook-pro = { url = "github:colemickens/wip-pinebook-pro/master"; flake = false; };
    wip-pinebook-pro.inputs.nixpkgs.follows = "nixpkgs";
    #wip-pinebook-pro = { url = "github:samueldr/wip-pinebook-pro"; flake = false; };

    nixpkgs-wayland  = { url = "github:nix-community/nixpkgs-wayland/master"; };
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";

    hardware = { url = "github:nixos/nixos-hardware"; };

    #nix-bitcoin = { url = "github:fort-nix/nix-bitcoin"; flake = false; };
    nix-bitcoin = { url = "github:erikarvstedt/nix-bitcoin/nixos-unstable"; flake = false; };
    #daedalus = { url = "github:input-output-hk/daedalus"; flake = false; };

    fenix = { url = "github:figsoda/fenix"; };
    fenix.inputs.nixpkgs.follows = "nixpkgs";

    # neovim-nightly = { url = "github:nix-community/neovim-nightly-overlay"; };
    # neovim-nightly.inputs.nixpkgs.follows = "nixpkgs";

    envfs = { url = "github:Mic92/envfs"; };
    envfs.inputs.nixpkgs.follows = "nixpkgs";

    # rust-overlay.url = "github:oxalica/rust-overlay";

    wfvm = { type = "git"; url = "https://git.m-labs.hk/M-Labs/wfvm"; flake = false;};

    nixos-mailserver = { url = "gitlab:simple-nixos-mailserver/nixos-mailserver"; };
    nixos-mailserver.inputs.nixpkgs.follows = "nixpkgs";

    nickel = { url = "github:tweag/nickel"; };

    hydra = { url = "github:NixOS/hydra"; };
    #hydra.inputs.nixpkgs.follows = "nixpkgs";

    tow-boot = { url = "github:tow-boot/tow-boot"; flake = false; };
  };

  outputs = inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      supportedSystems = [ "x86_64-linux" "aarch64-linux" "armv6l-linux" "armv7l-linux" ];
      forAllSystems = genAttrs supportedSystems;
      filterPkg_ = system: (pkg: (builtins.elem "${system}" (pkg.meta.platforms or [ "x86_64-linux" "aarch64-linux" ]) && !(pkg.meta.broken or false)));
      filterPkgs = pkgs: pkgSet: (pkgs.lib.filterAttrs (filterPkg_ pkgs.system) pkgSet.${pkgs.system});
      filterHosts = pkgs: cfgs: (pkgs.lib.filterAttrs (n: v: pkgs.system == v.config.nixpkgs.system) cfgs);
      filterPkgs_ = pkgs: pkgSet: (builtins.filter (filterPkg_ pkgs.system) (builtins.attrValues pkgSet.${pkgs.system}));
      filterHosts_ = pkgs: cfgs: (builtins.filter (c: pkgs.system == c.config.nixpkgs.system) (builtins.attrValues cfgs));
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
    in rec {
      internals = { inherit pkgs_ fullPkgs_; };
      devShell = forAllSystems (system: minimalMkShell system {
        name = "nixcfg-devshell";
        nativeBuildInputs = map (x: (x.bin or x.out or x))
          ((with pkgs_.nixpkgs.${system}; [
            nixUnstable
            bash curl cacert jq parallel mercurial git
            nettools openssh ripgrep rsync sops gh gawk gnused gnugrep
            cachix nix-prefetch-git
            tailscale
            # nix-build-uncached
          ]) ++ [
            fullPkgs_.${system}.metal-cli
            fullPkgs_.${system}.nix-build-uncached
          ]);
      });

      apps = forAllSystems (system: {
        # this is to have a minimal deriv to build/dl/run early on in CI jobs
        # we want to have a chance to load the devShell from cache using the CI's cache mechanism
        install-secrets = {
          type = "app";
          # ugh, dupe in/from legacyPackages so we can both easily build *and* run this, wtf nix cli
          # maybe just map these in from legacyPackages? maybe not
          program = legacyPackages."${system}".install-secrets.outPath;
        };
      });

      legacyPackages = forAllSystems (system: {
        # to `nix eval` the "currentSystem" in certain scenarios
        devShellSrc = inputs.self.devShell.${system}.inputDerivation;
        install-secrets = (import ./.github/secrets.nix { nixpkgs = inputs.nixpkgs; inherit inputs system; });
        bundle = inputs.self.bundles."${system}";
      });
      packages = forAllSystems (system: fullPkgs_.${system}.colePackages);
      pkgs = forAllSystems (system: fullPkgs_.${system});

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
          passrs = prev.callPackage ./pkgs/passrs {};
          poweralertd = prev.callPackage ./pkgs/poweralertd {};
          rkvm = prev.callPackage ./pkgs/rkvm {};
          shreddit = prev.python3Packages.callPackage ./pkgs/shreddit {};
          metal-cli = prev.callPackage ./pkgs/metal-cli {};
          # UGH : #v4l2rtspserver = prev.callPackage ./pkgs/v4l2rtspserver {};
          rtsp-simple-server = prev.callPackage ./pkgs/rtsp-simple-server {};
          zellij = prev.callPackage ./pkgs/zellij { zellij = prev.zellij; };

          nix-build-uncached = prev.nix-build-uncached.overrideAttrs(old: {
            src = prev.fetchFromGitHub {
              owner = "colemickens";
              repo = "nix-build-uncached";
              rev = "36ea105"; sha256 = "sha256-Ovx+q5pdfg+yIF5HU7pV0nR6nnoTa3y/f9m4TV0XXc0=";
            };
          });

          #disabled:
          #niche = prev.callPackage ./pkgs/niche {};
          # neochat_ = prev.libsForQt5.callPackage ./pkgs/neochat {
          #  neochat = prev.neochat;
          # };
          #raspberrypi-eeprom = prev.callPackage ./pkgs/raspberrypi-eeprom {};
          #rpi4-uefi = prev.callPackage ./pkgs/rpi4-uefi {};
          #cpptoml = prev.callPackage ./pkgs/cpptoml {};
          #wireplumber = prev.callPackage ./pkgs/wireplumber {};
          #libquotient = prev.libsForQt5.callPackage ./pkgs/quaternion/libquotient.nix {};
          #quaternion = prev.libsForQt5.callPackage ./pkgs/quaternion {};
        }; in p // { colePackages = p; };

      nixosModules = {
        hydra-auto = import ./modules/hydra-auto.nix;
        otg = import ./modules/otg.nix;
        other-arch-vm = import ./modules/other-arch-vm.nix;
      };

      nixosConfigurations = {
        # x86_64-linux
        jeffhyper = mkSystem inputs.nixpkgs "x86_64-linux"  "jeffhyper";
        porty     = mkSystem inputs.nixpkgs "x86_64-linux"  "porty";
        raisin    = mkSystem inputs.nixpkgs "x86_64-linux"  "raisin";
        xeep      = mkSystem inputs.nixpkgs "x86_64-linux"  "xeep";
        # aarch64-linux
        pinebook    = mkSystem inputs.nixpkgs "aarch64-linux" "pinebook";
        pinephone   = mkSystem inputs.nixpkgs "aarch64-linux" "pinephone";
        rpifour1    = mkSystem inputs.nixpkgs "aarch64-linux" "rpifour1";
        sinkor      = mkSystem inputs.nixpkgs "aarch64-linux" "sinkor";
        oracular    = mkSystem inputs.nixpkgs "aarch64-linux" "oracular";
        oracular_kexec  = mkSystem inputs.nixpkgs "aarch64-linux" "oracular/installer";
        # armv6l-linux (cross-built)
        rpizero1 = mkSystem inputs.crosspkgs "x86_64-linux" "rpizero1";
        rpizero2 = mkSystem inputs.crosspkgs "x86_64-linux" "rpizero2";
        # other
        bluephone     = mkSystem inputs.nixpkgs "aarch64-linux" "bluephone";
        #demovm      = mkSystem fullPkgs_.x86_64-linux  "demovm";
        #testipfsvm  = mkSystem fullPkgs_.x86_64-linux  "testipfsvm";
      };
      toplevels = genAttrs
        (builtins.attrNames inputs.self.outputs.nixosConfigurations)
        (attr: nixosConfigurations.${attr}.config.system.build.toplevel);

      # hydraSpecs =
      #   let
      #     nfj = b: hydralib.flakeJob "github:colemickens/nixcfg/${b}";
      #   in {
      #     jobsets = hydralib.makeSpec {
      #       nixcfg-main        = nfj "main";
      #       nixcfg-auto-update = nfj "auto-update";
      #     };
      #   };

      # TODO : clamped to x86_64 - undo!
      hydraJobs = genAttrs [ "aarch64-linux" "x86_64-linux" ] (system:
        {
          devshell = inputs.self.devShell.${system}.inputDerivation;
          selfPkgs = filterPkgs pkgs_.nixpkgs.${system} inputs.self.packages;
          hosts = (builtins.mapAttrs (n: v: v.config.system.build.toplevel)
            (filterHosts pkgs_.nixpkgs.${system} inputs.self.nixosConfigurations));
        });

      bundle_pkgs = genAttrs [ "aarch64-linux" "x86_64-linux" ] (system:
        pkgs_.nixpkgs."${system}".linkFarmFromDrvs "${system}-pkgs" ([]
          ++ (filterPkgs_ pkgs_.nixpkgs.${system} inputs.self.packages)
        ));
      bundle_hosts = genAttrs [ "aarch64-linux" "x86_64-linux" ] (system:
        pkgs_.nixpkgs."${system}".linkFarmFromDrvs "${system}-hosts" ([]
          ++ (builtins.map (host: host.config.system.build.toplevel)
               (filterHosts_ pkgs_.nixpkgs.${system} inputs.self.nixosConfigurations))
        ));
      bundles = genAttrs [ "aarch64-linux" "x86_64-linux" ] (system:
        pkgs_.nixpkgs."${system}".linkFarmFromDrvs "${system}-bundle" ([]
          ++ [ inputs.self.devShell.${system}.inputDerivation ]
          ++ (filterPkgs_ pkgs_.nixpkgs.${system} inputs.self.packages)
          ++ (builtins.map (host: host.config.system.build.toplevel)
               (filterHosts_ pkgs_.nixpkgs.${system} inputs.self.nixosConfigurations))
        ));

      images = let
        tow-boot = sys: (import inputs.tow-boot { pkgs = import inputs.nixpkgs { system = sys; }; });
        tow-boot-aarch64 = tow-boot "aarch64-linux";
      in {
        rpifour1_towboot = tow-boot-aarch64.raspberryPi4.sharedImage;
        sinkor_towboot = tow-boot-aarch64.outputs.raspberryPi4.sharedImage;
        pinebook_towboot = tow-boot-aarch64.pinebook.sharedImage;

        # azure vhd for azdev machine (a custom Azure image using `nixos-azure` module)
        azdev = inputs.self.nixosConfigurations.azdev.config.system.build.azureImage;
        azmail = inputs.self.nixosConfigurations.azmail.config.system.build.azureImage;
        awsone = inputs.self.nixosConfigurations.awsone.config.system.build.amazonImage;
        newimg = inputs.self.nixosConfigurations.rpitwoefi.config.system.build.newimg;

        rpizero1  = inputs.self.nixosConfigurations.rpizero1.config.system.build.sdImage;
        rpizero2  = inputs.self.nixosConfigurations.rpizero2.config.system.build.sdImage;
        rpionebp  = inputs.self.nixosConfigurations.rpionebp.config.system.build.sdImage;

        oracular_kexec = inputs.self.nixosConfigurations.oracular_kexec.config.system.build.kexec_tarball;

        pinebook_bundle = let wpp = inputs.wip-pinebook-pro.packages.aarch64-linux; in
          pkgs_.nixpkgs.aarch64-linux.runCommandNoCC "pinebook-bundle" {} ''
            mkdir $out
            ln -s "${toplevels.pinebook.toplevel}" $out/toplevel
            ln -s "${wpp.uBootPinebookPro}" $out/uboot
            ln -s "${wpp.pinebookpro-keyboard-updater}" $out/kbfw
          '';

        bluephone_bootimg =
          let
            dev = inputs.self.nixosConfigurations.bluephone;
          in
            dev.config.mobile.outputs.android.android-bootimg;

        pinephone_bundle = let
          p = nixosConfigurations.pinephone.config.mobile.outputs;
        in
          pkgs_.nixpkgs.aarch64-linux.runCommandNoCC "pinephone-bundle" {} ''
            mkdir $out

            # uboot
            #ln -s "''${p.u-boot}" $out/uboot;

            # full image
            # inf recursion with mobile-nixos/master :(
            #ln -s "${p.disk-image}" $out/disk-image;

            # boot partition
            # inf recursion with mobile-nixos/master :(
            #ln -s "''${p.boot-partition}" $out/boot-partition;
          '';
      };
      linuxVMs = {
        demovm = inputs.self.nixosConfigurations.demovm.config.system.build.vm;
        testipfsvm = inputs.self.nixosConfigurations.testipfsvm.config.system.build.vm;
      };
      winVMs = {
        nixwinvm = import ./hosts/nixwinvm {
          pkgs = pkgs_.nixpkgs.x86_64-linux;
          inherit inputs;
        };
      };

      experiments = {
        nixbox = {
          dash = import ./hosts/nixbox/dashboard.nix { inherit inputs; };
          linux = import ./hosts/nixbox/linux.nix { inherit inputs; };
        };
      };
    };
}
