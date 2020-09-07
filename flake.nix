{
  description = "colemickens-nixcfg";

  # flakes feedback
  # - i wish inputs were optional so that I could do my current logic
  # ---- they're CLI overrideable?
  # - i hate the git url syntax

  # cached failure isn't actually showing me the ... error?
  # how to use local paths when I want to?

  # nix build is UNRELIABLE because /soemtimes/ it checks for updates, I hate this
  # unpredictable, moves underneath me

  # credits: bqv, balsoft
  inputs = {
    nixpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; }; # for my regular nixpkgs
    master = { url = "github:nixos/nixpkgs/master"; }; # for nixFlakes
    stable = { url = "github:nixos/nixpkgs/nixos-20.03"; }; # for cachix

    home-manager.url = "github:colemickens/home-manager/cmhm";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    construct.url = "github:matrix-construct/construct";
    construct.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix/master";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    firefox  = { url = "github:colemickens/flake-firefox-nightly"; };
    firefox.inputs.nixpkgs.follows = "nixpkgs";

    chromium  = { url = "github:colemickens/flake-chromium"; };
    chromium.inputs.nixpkgs.follows = "nixpkgs";

    nixos-veloren = { url = "github:colemickens/nixos-veloren"; };
    nixos-veloren.inputs.nixpkgs.follows = "nixpkgs";

    mobile-nixos = { url = "github:colemickens/mobile-nixos"; };
    mobile-nixos.inputs.nixpkgs.follows = "nixpkgs";

    wip-pinebook-pro = { url = "github:colemickens/wip-pinebook-pro"; };
    wip-pinebook-pro.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs-wayland  = { url = "github:colemickens/nixpkgs-wayland"; };
    # these are kind of weird, they don't really apply
    # to me if I'm using just  `wayland#overlay`, afaict?
    nixpkgs-wayland.inputs.nixpkgs.follows = "nixpkgs";
    nixpkgs-wayland.inputs.master.follows = "master";

    hardware = { url = "github:nixos/nixos-hardware"; };

    wfvm = { type = "git"; url = "https://git.m-labs.hk/M-Labs/wfvm"; flake = false;};
  };

  outputs = inputs:
    let
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      forAllSystems = genAttrs [ "x86_64-linux" "i686-linux" "aarch64-linux" ];

      pkgsFor = pkgs: sys:
        import pkgs {
          system = sys;
          config = { allowUnfree = true; };
        };

      mkSystem = sys: pkgs_: hostname:
        pkgs_.lib.nixosSystem {
          system = sys;
          modules = [(./. + "/machines/${hostname}/configuration.nix")];
          specialArgs = { inherit inputs; };
        };
    in rec {
      devShell = forAllSystems (system:
        (pkgsFor inputs.nixpkgs system).mkShell {
          nativeBuildInputs = with (pkgsFor inputs.nixpkgs system); [
            (pkgsFor inputs.master system).nixFlakes
            (pkgsFor inputs.stable system).cachix
            bash cacert curl git jq mercurial
            nettools openssh ripgrep rsync
            nix-build-uncached nix-prefetch-git
            packet-cli
            sops
          ];
        }
      );

      # packages = // import nixpkgs, expose colePkgs

      nixosConfigurations = {
        # cloud VMs
        azdev  = mkSystem "x86_64-linux" inputs.nixpkgs "azdev";

        # raspberry Pis
        rpione = mkSystem "aarch64-linux" inputs.nixpkgs "rpione";
        rpitwo = mkSystem "aarch64-linux" inputs.nixpkgs "rpitwo";

        # Gaming PC VM / Linux workstation
        slynux = mkSystem "x86_64-linux"  inputs.nixpkgs "slynux";

        # laptops
        xeep     = mkSystem "x86_64-linux"  inputs.nixpkgs "xeep";
        pinebook = mkSystem "aarch64-linux" inputs.nixpkgs "pinebook";

        # phones
        pinephone = mkSystem "aarch64-linux" inputs.nixpkgs "pinephone";
      };

      machines = {
        azdev = inputs.self.nixosConfigurations.azdev.config.system.build.azureImage;
        xeep = inputs.self.nixosConfigurations.xeep.config.system.build.toplevel;
        slynux = inputs.self.nixosConfigurations.slynux.config.system.build.toplevel;
        rpione = inputs.self.nixosConfigurations.rpione.config.system.build.toplevel;
        rpitwo = inputs.self.nixosConfigurations.rpitwo.config.system.build.toplevel;

        pinebook = (pkgsFor inputs.nixpkgs "aarch64-linux").runCommandNoCC "pinebook-bundle" {} ''
          mkdir $out
          ln -s "${inputs.self.nixosConfigurations.pinebook.config.system.build.toplevel}" $out/toplevel
          ln -s "${inputs.wip-pinebook-pro.packages.aarch64-linux.uBootPinebookPro}" $out/uboot
          ln -s "${inputs.wip-pinebook-pro.packages.aarch64-linux.pinebookpro-keyboard-updater}" $out/kbfw
        '';

        pinephone = let
          dev = inputs.self.nixosConfigurations.pinephone;
        in
          (pkgsFor inputs.nixpkgs "aarch64-linux").runCommandNoCC "pinephone-bundle" {} ''
          mkdir $out
          ln -s "${dev.config.system.build.disk-image}" $out/disk-image;
          ln -s "${dev.config.system.build.toplevel}" $out/toplevel;
          ln -s "${dev.config.system.build.u-boot}" $out/uboot;
          ln -s "${dev.config.system.build.boot-partition}" $out/boot-partition;
        '';

        # Nix-built Windows 10 VM
        winvm = import ./machines/winvm {
          pkgs = pkgsFor inputs.cmpkgs "x86_64-linux";
          inherit inputs;
        };
      };
    };
}

