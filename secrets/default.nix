{ pkgs, lib, inputs, ... }:

let
  secrets = import ./secretdata.nix {lib=lib;};
in {
  imports = [
    inputs.sops-nix.nixosModules.sops
  ];
  config = {
    sops = {
      # externalAuthVars = {
      #   AZURE_AUTH_MODE = "msi";
      # };
      secrets = secrets;
    };
  };
}
