{ pkgs, lib, ... }:

let
  encrypted_files = lib.mapAttrs' (name: v: (lib.nameValuePair name {
    sopsFile = builtins.trace (./encrypted + "/${name}") (./encrypted + "/${name}");
    format = "binary";
    externalAuth.enable = true;
    externalAuth.environmentVariables = {
      AZURE_AUTH_MODE="msi";
    };
  })) (builtins.readDir ./encrypted);
in {
  config = {
    sops.secrets = encrypted_files;
  };
}
