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

    nix.url = "github:nixos/nix/flakes";
    nix.inputs.nixpkgs.follows = "master";

    home.url = "github:colemickens/home-manager/cmhm";
    home.inputs.nixpkgs.follows = "cmpkgs";

    construct.url = "github:matrix-construct/construct";
    construct.inputs.nixpkgs.follows = "cmpkgs";

    firenight  = { url = "github:colemickens/flake-firefox-nightly"; };
    firenight.inputs.nixpkgs.follows = "cmpkgs";

    wayland  = { url = "github:colemickens/nixpkgs-wayland"; };
    # these are kind of weird, they don't really apply
    # to me if I'm using just  `wayland#overlay`, afaict?
    wayland.inputs.nixpkgs.follows = "cmpkgs";
    wayland.inputs.master.follows = "master";

    hardware = { url = "github:nixos/nixos-hardware"; };
  };

  outputs = inputs:
    let
      uniformVersionSuffix = true; # clamp versionSuffix to ".git" to get identical build to non-flakes

      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      forAllSystems = genAttrs [ "x86_64-linux" "i686-linux" "aarch64-linux" ];

      pkgsFor = pkgs: system:
        import pkgs {
          inherit system;
          config = { allowUnfree = true; };
          # overlays = if false then [] else [
          #   inputs.wayland.overlay
          # ];
        };

      mkSystem = system: pkgs_: hostname:
        #(pkgsFor pkgs_ system).lib.nixosSystem {
        pkgs_.lib.nixosSystem {
          inherit system;
          modules = [(./. + "/machines/${hostname}/configuration.nix")]
            ++ (if uniformVersionSuffix then
                [({config, lib, ...}: {
                    system.nixos.revision = lib.mkForce "git";
                    system.nixos.versionSuffix = lib.mkForce ".git";
                })] else []);
          specialArgs.inputs = inputs;
        };
    in rec {
      # defaultPackage.x86_64-linux =
      #   nixosConfigurations.xeep.config.system.build.toplevel;

      devShell = forAllSystems (system:
        (pkgsFor inputs.unstable system).mkShell { # TODO: "legacy" packages, doesn't work for mkShell why?
          nativeBuildInputs = with (pkgsFor inputs.unstable system); [
            (pkgsFor inputs.master system).nixFlakes
            (pkgsFor inputs.stable system).cachix
            bash cacert curl git jq mercurial
            nettools openssh ripgrep rsync
            nix-build-uncached nix-prefetch-git
          ];
        }
      );

      nixosConfigurations = {
        azdev     = mkSystem "x86_64-linux" inputs.unstable "azdev";
        raspberry = mkSystem "aarch64-linux" inputs.pipkgs "raspberry";
        #fastraz   = mkSystem "aarch64-linux" inputs.cmpkgs "raspberry";
        torob-fe    = mkSystem "aarch64-linux" inputs.cmpkgs "torob-fe";
        torob-be    = mkSystem "aarch64-linux" inputs.cmpkgs "torob-be";
        xeep      = mkSystem "x86_64-linux"  inputs.cmpkgs "xeep";
        xeep_     = mkSystem "x86_64-linux"  inputs.cmpkgs "xeep";
      };

      machines = {
        azdev = inputs.self.nixosConfigurations.azdev.config.system.build.azureImage;
        xeep = inputs.self.nixosConfigurations.xeep.config.system.build.toplevel;
        raspberry = inputs.self.nixosConfigurations.raspberry.config.system.build.toplevel;
      };

      defaultPackage = [
        inputs.self.nixosConfigurations.xeep.config.system.build.toplevel
        inputs.self.nixosConfigurations.raspberry.config.system.build.toplevel
      ];
    };
}
