{
  # flakes feedback
  # - flake-overrides.nix: https://github.com/NixOS/nix/issues/4193
  # - I dislike the special-cased GitHub special URL syntax
  # shout-outs to: @bqv, @balsoft, @cole-h for flake.nix inspriation

  description = "colemickens-nixcfg";

  inputs = {
    nixpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; }; # for my regular nixpkgs
    nixos-unstable = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    master = { url = "github:nixos/nixpkgs/master"; }; # for nixFlakes
    stable = { url = "github:nixos/nixpkgs/nixos-20.09"; }; # for cachix

    nix.url = "github:nixos/nix/master";
    #nix.inputs.nixpkgs.follows = "nixpkgs";

    niche.url = "github:colemickens/niche/master";
    niche.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:colemickens/home-manager/cmhm";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    construct.url = "github:matrix-construct/construct";
    construct.inputs.nixpkgs.follows = "nixpkgs";

    #sops-nix.url = "github:Mic92/sops-nix/master";
    sops-nix.url = "github:colemickens/sops-nix/wip";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    deploy-rs.url = "github:colemickens/deploy-rs";
    deploy-rs.inputs.nixpkgs.follows = "nixpkgs";

    firefox  = { url = "github:colemickens/flake-firefox-nightly"; };
    firefox.inputs.nixpkgs.follows = "nixpkgs";

    chromium  = { url = "github:colemickens/flake-chromium"; };
    chromium.inputs.nixpkgs.follows = "nixpkgs";

    nixos-veloren = { url = "github:colemickens/nixos-veloren"; };
    nixos-veloren.inputs.nixpkgs.follows = "nixpkgs";

    mobile-nixos = { url = "github:colemickens/mobile-nixos/mobile-nixos-blueline"; };
    mobile-nixos.inputs.nixpkgs.follows = "nixpkgs";

    nix-ipfs = { url = "github:obsidiansystems/nix"; };

    nixos-azure = { url = "github:colemickens/nixos-azure/dev"; };
    nixos-azure.inputs.nixpkgs.follows = "nixpkgs";

    wip-pinebook-pro = { url = "github:colemickens/wip-pinebook-pro"; };
    wip-pinebook-pro.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-wayland  = { url = "github:colemickens/nixpkgs-wayland"; };
    # these are kind of weird, they don't really apply
    # to me if I'm using just  `wayland#overlay`, afaict?
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";

    hardware = { url = "github:nixos/nixos-hardware"; };

    wfvm = { type = "git"; url = "https://git.m-labs.hk/M-Labs/wfvm"; flake = false;};
  };

  outputs = inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];
      forAllSystems = genAttrs supportedSystems;

      pkgsFor = pkgs: sys: import pkgs {
        system = sys;
        config = { allowUnfree = true; };
      };
      pkgs_ = genAttrs (builtins.attrNames inputs) (inp: genAttrs supportedSystems (sys: pkgsFor inputs."${inp}" sys));

      mkSystem = sys: pkgs_: hostname:
        pkgs_.lib.nixosSystem {
          system = sys;
          modules = [(./. + "/hosts/${hostname}/configuration.nix")];
          specialArgs = { inherit inputs; };
        };
    in rec {
      devShell = forAllSystems (system:
        pkgs_.nixpkgs.${system}.mkShell {
          name = "nixcfg-devshell";
          nativeBuildInputs = []
          #++ ([ inputs.nix.defaultPackage.${system} ])
          ++ (with pkgs_.stable.${system}; [ cachix ])
          ++ (with inputs.niche.packages.${system}; [ niche ])
          ++ (with pkgs_.nixpkgs.${system}; [
            nixUnstable
            bash cacert curl git jq
            mercurial
            nettools openssh ripgrep rsync
            nix-build-uncached nix-prefetch-git
            packet-cli
            sops oil awsweeper
            (writeScriptBin "awsweeper-tag" ''
              #!/usr/bin/env bash
              set -x
              t=$(mktemp)
              cat <<EOF >''${t}
              aws_instance: [ { "tags": { "project": "''${1}" } } ]
              aws_internet_gateway: [ { "tags": { "project": "''${1}" } } ]
              aws_route_table: [ { "tags": { "project": "''${1}" } } ]
              aws_security_group: [ { "tags": { "project": "''${1}" } } ]
              aws_subnet: [ { "tags": { "project": "''${1}" } } ]
              aws_vpc: [ { "tags": { "project": "''${1}" } } ]
              EOF
              ${awsweeper}/bin/awsweeper --region "us-west-2" ''${t}
            '')
          ])
          ;
        }
      );

      packages = forAllSystems (system:
        let
          pkgs = import inputs.nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
            overlays = [ inputs.self.overlay ];
          };
          accept = pkg: pkg.meta.platforms or [ "x86_64-linux" "aarch64-linux" ];
          filter = (name: pkg: builtins.elem "${system}" (accept pkg));
        in {
          pkgs = import inputs.nixpkgs {
            system = system;
            config = { allowUnfree = true; };
            overlays = [
              inputs.self.overlay
              inputs.nixpkgs-wayland.overlay
            ];
          };
        } // (pkgs.lib.filterAttrs filter pkgs.colePackages)
      );

      # TODO: eventually maybe we should only compose nixpkgs here, and then make a unified,
      # overlaid nixpkgs available, both as an output and as 'nixpkgs' for our systems?

      overlay = final: prev:
        let p = rec {
          customCommands = prev.callPackage ./pkgs/commands.nix {};
          customGuiCommands = prev.callPackage ./pkgs/commands-gui.nix {};

          bb = prev.callPackage ./pkgs/bb {};
          cchat-gtk = prev.callPackage ./pkgs/cchat-gtk {};
          conduit = prev.callPackage ./pkgs/conduit {};
          drm-howto = prev.callPackage ./pkgs/drm-howto {};
          get-xoauth2-token = prev.callPackage ./pkgs/get-xoauth2-token {};
          #mesa-git = prev.callPackage ./pkgs/mesa-git {};
          mirage-im = prev.libsForQt5.callPackage ./pkgs/mirage-im {};
          meli = prev.callPackage ./pkgs/meli {};
          neovim-unwrapped = prev.callPackage ./pkgs/neovim {
            neovim-unwrapped = prev.neovim-unwrapped;
          };
          #niche = prev.callPackage ./pkgs/niche {};
          obs-v4l2sink = prev.libsForQt5.callPackage ./pkgs/obs-v4l2sink {};
          passrs = prev.callPackage ./pkgs/passrs {};
          rkvm = prev.callPackage ./pkgs/rkvm {};
          # tree-sitter = prev.callPackage ./pkgs/tree-sitter {
          #   tree-sitter = prev.tree-sitter;
          # };

          libquotient = prev.libsForQt5.callPackage ./pkgs/quaternion/libquotient.nix {};
          quaternion = prev.libsForQt5.callPackage ./pkgs/quaternion {};

          raspberrypi-eeprom = prev.callPackage ./pkgs/raspberrypi-eeprom {};
          rpi4-uefi = prev.callPackage ./pkgs/rpi4-uefi {};

          cpptoml = prev.callPackage ./pkgs/cpptoml {};
          wireplumber = prev.callPackage ./pkgs/wireplumber {};
        }; in p // { colePackages = p; };

      nixosConfigurations = {
        azdev      = mkSystem "x86_64-linux"  inputs.nixpkgs "azdev";
        rpione     = mkSystem "aarch64-linux" inputs.nixpkgs "rpione";
        rpitwo     = mkSystem "aarch64-linux" inputs.nixpkgs "rpitwo";
        rpitwoefi  = mkSystem "aarch64-linux" inputs.nixpkgs "rpitwoefi";
        rpitwonet  = mkSystem "aarch64-linux" inputs.nixpkgs "rpitwonet";
        slynux     = mkSystem "x86_64-linux"  inputs.nixpkgs "slynux";
        xeep       = mkSystem "x86_64-linux"  inputs.nixpkgs "xeep";
        pinephone  = mkSystem "aarch64-linux" inputs.nixpkgs "pinephone";
        pinebook   = mkSystem "aarch64-linux" inputs.nixpkgs "pinebook";
        bluephone  = mkSystem "aarch64-linux" inputs.nixpkgs "bluephone";

        demovm = mkSystem "x86_64-linux"  inputs.nixpkgs "demovm";
        testipfsvm = mkSystem "x86_64-linux"  inputs.nixpkgs "testipfsvm";
      };
      toplevels = genAttrs
        (builtins.attrNames inputs.self.outputs.nixosConfigurations)
        (attr: nixosConfigurations.${attr}.config.system.build.toplevel);

      bundles = rec {
        x86_64-linux = pkgs_.nixpkgs.x86_64-linux.linkFarmFromDrvs "x86_64-linux-outputs" ([
            # regular toplevels/hosts/vms
            inputs.self.nixosConfigurations.azdev.config.system.build.toplevel
            inputs.self.nixosConfigurations.slynux.config.system.build.toplevel
            # relevant devShells
            inputs.self.devShell.x86_64-linux
        ] ++ builtins.attrValues inputs.self.outputs.packages.x86_64-linux);
        aarch64-linux = pkgs_.nixpkgs.aarch64-linux.linkFarmFromDrvs "aarch64-linux-outputs" ([
          inputs.self.nixosConfigurations.rpione.config.system.build.toplevel
          inputs.self.nixosConfigurations.pinebook.config.system.build.toplevel
          #shells
        ] ++ builtins.attrValues inputs.self.outputs.packages.aarch64-linux);
      };
      images = {
        # azure vhd for azdev machine (a custom Azure image using `nixos-azure` module)
        azdev = inputs.self.nixosConfigurations.azdev.config.system.build.azureImage;

        newimg = inputs.self.nixosConfigurations.rpitwoefi.config.system.build.newimg;

        pinebook_bundle = pkgs_.nixpkgs.aarch64-linux.runCommandNoCC "pinebook-bundle" {} ''
          mkdir $out
          ln -s "${inputs.self.nixosConfigurations.pinebook.config.system.build.toplevel}" $out/toplevel
          ln -s "${inputs.wip-pinebook-pro.packages.aarch64-linux.uBootPinebookPro}" $out/uboot
          ln -s "${inputs.wip-pinebook-pro.packages.aarch64-linux.pinebookpro-keyboard-updater}" $out/kbfw
        '';
        bluephone_bootimg =
          let
            dev = inputs.self.nixosConfigurations.bluephone;
          in
            dev.config.system.build.android-bootimg;

        pinephone_bundle =
          let
            dev = mkSystem "aarch64-linux" inputs.nixpkgs "pinephone";
          in
            pkgs_.nixpkgs.aarch64-linux.runCommandNoCC "pinephone-bundle" {} ''
            mkdir $out
            ln -s "${dev.config.system.build.disk-image}" $out/disk-image;
            ln -s "${dev.config.system.build.u-boot}" $out/uboot;
            ln -s "${dev.config.system.build.boot-partition}" $out/boot-partition;
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
    };
}
