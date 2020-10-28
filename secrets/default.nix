{ pkgs, lib, ... }:

let
  encrypted_files = lib.mapAttrs' (name: v: (lib.nameValuePair name {
    sopsFile =  ./encrypted + "/${name}";
    format = "binary";
  })) (builtins.readDir ./encrypted);
in {
  config = {
    sops = {
      # externalAuthVars = {
      #   AZURE_AUTH_MODE = "msi";
      # };
      secrets = encrypted_files;
    };
  };
}
