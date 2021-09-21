{ nixpkgs, system, inputs }:

let
  pkgs = import nixpkgs { inherit system; };

  secretdata = import ../secrets/secretdata.nix {lib=pkgs.lib;};
  secrets = pkgs.lib.mapAttrs (k: v: v //
    {
      owner = "runner";
      group = "runner";
    }
  ) secretdata;

  fakeSystem = (nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [
      inputs.sops-nix.nixosModules.sops

      ({config,lib,pkgs,...}:
      {
        config.sops.secrets = secrets;
      })
    ];
    specialArgs = { inherit inputs; };
  });
in
  pkgs.writeShellScript "setup-secrets" ''
    ${fakeSystem.config.system.activationScripts.setup-secrets.text}
  ''
