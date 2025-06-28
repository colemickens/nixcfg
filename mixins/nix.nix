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
      nixPath = lib.mkForce [ "nixpkgs=${inputs.cmpkgs.outPath}" ];
      settings = rec {
        keep-derivations = true; # this is the default (?)
        builders-use-substitutes = true;
        cores = lib.mkDefault 0;
        max-jobs = lib.mkDefault "auto";
        use-xdg-base-directories = true;
        trusted-public-keys = [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "colemickens.cachix.org-1:bNrJ6FfMREB4bd4BOjEN85Niu8VcPdQe4F4KxVsb/I4="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "cosmic.cachix.org-1:Dya9IyXD4xdBehWjrkPv6rtxpmMdRel02smYzA85dPE="
        ];
        trusted-substituters = [
          "https://cache.nixos.org"
          "https://colemickens.cachix.org"
          "https://nix-community.cachix.org"
          "https://cosmic.cachix.org"
        ];
        substituters = trusted-substituters;
        trusted-users = [
          "@wheel"
          "cole"
          "root"
        ];
      };
      extraOptions = ''
        !include ${config.sops.secrets.nix-access-tokens.path}
      '';
    };
  };
}
