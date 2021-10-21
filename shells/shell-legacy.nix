{ inputs, system, minimalMkShell }:

let
  pkgs = inputs.stable.legacyPackages.${system};
in minimalMkShell pkgs.system { # TODO use something else for system?
  name = "legacy";

  nativeBuildInputs = with pkgs; [
    nix
  ];
}
