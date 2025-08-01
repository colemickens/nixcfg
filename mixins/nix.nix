{
  config,
  lib,
  inputs,
  ...
}:

{
  config = {
    sops.secrets = {
      "nix-access-tokens" = {
        owner = "cole";
        sopsFile = ../secrets/encrypted/nix-access-tokens;
        format = "binary";
      };
    };

    nixpkgs = {
      config = {
        allowAliases = false;
      };
    };
    nix = {
      settings = {
        keep-derivations = true; # this is the default (?)
        builders-use-substitutes = true;
        cores = lib.mkDefault 0;
        max-jobs = lib.mkDefault "auto";
        use-xdg-base-directories = true;
        extra-trusted-public-keys = [
          "colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4="
        ];
        extra-substituters = [
          "https://colemickens.cachix.org"
        ];
        extra-trusted-substituters = [
          "https://colemickens.cachix.org"
        ];
        trusted-users = [
          "@wheel"
          "cole"
          "root"
        ];
      };
      registry = {
        self = {
          flake = inputs.self;
        };

        cmpkgs = {
          from = {
            id = "cmpkgs";
            type = "indirect";
          };
          flake = inputs.cmpkgs;
        };
      };
      extraOptions = ''
        lazy-trees = true
        !include ${config.sops.secrets.nix-access-tokens.path}
      '';
    };
  };
}
