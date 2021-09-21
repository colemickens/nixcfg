{ nixpkgs, system, inputs }:

let
  pkgs = import nixpkgs { inherit system; };
  fakeSystem = (nixpkgs.lib.nixosSystem {
    inherit system;
    modules = [ ../secrets ];
  });
in
  pkgs.writeShellScript "setup-secrets" ''
    ${fakeSystem.config.system.activationScripts.setup-secrets.text}
  ''
