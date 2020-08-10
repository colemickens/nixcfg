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
    master = { url = "github:nixos/nixpkgs/master"; };
    stable = { url = "github:nixos/nixpkgs/nixos-20.03"; };
    unstable = { url = "github:nixos/nixpkgs/nixos-unstable"; };
    cmpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; };
    pipkgs = { url = "github:colemickens/nixpkgs/pipkgs"; };

    home.url = "github:colemickens/home-manager/cmhm";
    home.inputs.nixpkgs.follows = "cmpkgs";

    construct.url = "github:matrix-construct/construct";
    construct.inputs.nixpkgs.follows = "cmpkgs";

    sops-nix.url = "github:Mic92/sops-nix/master";
    sops-nix.inputs.nixpkgs.follows = "cmpkgs";

    firefox  = { url = "github:colemickens/flake-firefox-nightly"; };
    firefox.inputs.nixpkgs.follows = "cmpkgs";

    chromium  = { url = "github:colemickens/flake-chromium"; };
    chromium.inputs.nixpkgs.follows = "cmpkgs";

    wayland  = { url = "github:colemickens/nixpkgs-wayland"; };
    # these are kind of weird, they don't really apply
    # to me if I'm using just  `wayland#overlay`, afaict?
    wayland.inputs.nixpkgs.follows = "cmpkgs";
    wayland.inputs.master.follows = "master";

    hardware = { url = "github:nixos/nixos-hardware"; };
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
          specialArgs = {
            inputs = inputs;
            #secrets = import ./secrets;
          };
        };
    in rec {
      devShell = forAllSystems (system:
        (pkgsFor inputs.unstable system).mkShell {
          nativeBuildInputs = with (pkgsFor inputs.cmpkgs system); [
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
        azdev  = mkSystem "x86_64-linux" inputs.unstable "azdev";
        rpione = mkSystem "aarch64-linux" inputs.pipkgs "rpione";
        xeep   = mkSystem "x86_64-linux"  inputs.cmpkgs "xeep";
      };

      machines = {
        azdev = inputs.self.nixosConfigurations.azdev.config.system.build.azureImage;
        xeep = inputs.self.nixosConfigurations.xeep.config.system.build.toplevel;
        rpione = inputs.self.nixosConfigurations.rpione.config.system.build.toplevel;
      };

      defaultPackage = [
        inputs.self.nixosConfigurations.xeep.config.system.build.toplevel
        inputs.self.nixosConfigurations.rpione.config.system.build.toplevel
      ];

      cyclopsJobs = {
        # 1. provision an age1 key
        # 2. get cyclops's advertised age1 pubkey
        # 3. add to .sops.yml
        # 4. ./util.sh e

        # cyclops:
        # - /nix is shared, but only per-customer
        # - same story with the cache
        xeep-update = {
          triggers = {
            cron = "*/*"; # use systemd format?
          };
          secrets = [
            { name="id_ed25519";   sopsFile = ./secrets/encrypted/id_ed25519;   path = "$HOME/.ssh/id_ed25519"; }
            { name="cachix.dhall"; sopsFile = ./secrets/encrypted/cachix.dhall; path = "$HOME/.cachix/cachix.dhall"; }
          ];
          stages = [
            # TODO: we can make some of these steps generic+shared, yay nix
            { name="prep";          script="./prep.sh"; }
            { name="update";        script="./update.sh"; }
            { name="build";         script="./build.sh"; }
            { name="update-flakes"; script="./update-flakes.sh"; }
          ];
        };
      };
    };
}
