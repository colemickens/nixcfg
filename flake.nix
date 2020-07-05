{
  description = "colemickens-nixcfg";

  # flakes feedback
  # - i wish inputs were optional so that I could do my current logic
  # ---- they're CLI overrideable?
  # - i hate the git url syntax

  # cached failure isn't actually showing me the ... error?
  # how to use local paths when I want to?

  # credits: bqv, balsoft
  inputs = {
    master = { url = "github:nixos/nixpkgs/master"; };
    stable = { url = "github:nixos/nixpkgs/nixos-20.03"; };
    cmpkgs = { url = "github:colemickens/nixpkgs/cmpkgs"; };
    pipkgs = { url = "github:colemickens/nixpkgs/pipkgs"; };

    nix.url = "github:nixos/nix/flakes";
    nix.inputs.nixpkgs.follows = "master";

    home.url = "github:colemickens/home-manager/cmhm-flakes";
    home.inputs.nixpkgs.follows = "cmpkgs";

    construct.url = "github:matrix-construct/construct";
    construct.inputs.nixpkgs.follows = "cmpkgs";

    nixops.url = "github:nixos/nixops/master";
    nixops.inputs.nixpkgs.follows = "cmpkgs";
    
    vimpluginsPkgs = { type = "path"; path = "/home/cole/code/nixpkgs/pulls/vimplugins"; };

    hardware = { url = "github:nixos/nixos-hardware";        flake = false; };
    mozilla  = { url = "github:mozilla/nixpkgs-mozilla";     flake = false; };
    wayland  = { url = "github:colemickens/nixpkgs-wayland"; flake = false; };
  };
  
  outputs = inputs:
    let
      uniformVersionSuffix = true; # clamp versionSuffix to ".git" to get identical build to non-flakes
      nameValuePair = name: value: { inherit name value; };
      genAttrs = names: f: builtins.listToAttrs (map (n: nameValuePair n (f n)) names);
      forAllSystems = genAttrs [ "x86_64-linux" "i686-linux" "aarch64-linux" ];

      pkgImport = pkgs: system:
        import pkgs {
          system = system;
          #overlays = builtins.attrValues inputs.self.overlays;
          config = { allowUnfree = true; };
        };

      mkSystem = hostname: pkgs_: system:
        pkgs_.lib.nixosSystem {
          inherit system;
          modules = [ (./. + "/machines/${hostname}/configuration.nix")]
            ++ (if uniformVersionSuffix then
                [({config, lib, ...}: {
                  system.nixos.revision = lib.mkForce "git";
                  system.nixos.versionSuffix = lib.mkForce ".git";
                })]
                else []);
          specialArgs = {
            inherit inputs;
          };
        };
      
      cmpkgs_ = (pkgImport inputs.cmpkgs "x86_64-linux");
      master_ = (pkgImport inputs.master "x86_64-linux");
      stable_ = (pkgImport inputs.cmpkgs "x86_64-linux");
    in rec {
      defaultPackage.x86_64-linux =
        nixosConfigurations.xeep.config.system.build;

      devShell = forAllSystems (system:
        import ./shell.nix {
          pkgs = cmpkgs_;
          masterPkgs = master_;
          cachixPkgs = stable_;
        }
      );

      nixosConfigurations = {
        raspberry = mkSystem "raspberry" inputs.pipkgs "aarch64-linux";
        xeep = mkSystem "xeep" inputs.cmpkgs "x86_64-linux";
      };
    };
}
