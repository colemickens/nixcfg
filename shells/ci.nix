{ pkgs, inputs, ... }:

let
  minimalMkShell = import ./_minimal.nix { inherit pkgs; };
in
minimalMkShell {
  name = "shell-ci";

  # shellHook = ''
  #   # activate secrets?
  # '';

  nativeBuildInputs = (
    (with pkgs; [
      cachix
      cacert
      dust
      git
      mercurial
      nushell
      nixpkgs-fmt
      openssh
      tailscale # so the github action job can deploy

      hcloud # for hetzner management
      nixos-anywhere # for initial hetzner deployment
      nixfmt-rfc-style
    ])
    ++ [
      # maybe drop, just use NFB for now:
      # inputs.nix-eval-jobs.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.nix-update.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.nix-fast-build.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default
      inputs.fast-flake-update.outputs.packages.${pkgs.stdenv.hostPlatform.system}.default
    ]
  );
}
