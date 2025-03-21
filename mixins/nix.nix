{
  config,
  lib,
  pkgs,
  inputs,
  ...
}:

with lib;

let
in
# _nixUnstableXdg = pkgs.nixUnstable.overrideAttrs (old: {
#   src = pkgs.fetchFromGitHub {
#     owner = "Artturin";
#     repo = "nix";
#     rev = "0c4a30eecc22a7e10cddba4612df484ade3e291f";
#     sha256 = "sha256-HNU+jltYw3gdt9ApI21zUoojy0aJ4y1x7kidkWZkKg0=";
#   };
# });
# _nix = pkgs.nixVersions.unstable;
# _nix = pkgs.nixVersions.nix_2_18;
# _nix = pkgs.nixVersions.latest;
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
      gc = {
        # automatic = true;
        options = "--delete-older-than 7d";
        randomizedDelaySec = "30min";
      };
      # nixPath = lib.mkForce [ ]; # i doth protest
      nixPath = lib.mkForce [ "nixpkgs=${inputs.cmpkgs.outPath}" ]; # i doth relent
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
          "cache.flakehub.com-3:hJuILl5sVK4iKm86JzgdXW12Y2Hwd5G07qKtHTOcDCM="
          "cache.flakehub.com-4:Asi8qIv291s0aYLyH6IOnr5Kf6+OF14WVjkE6t3xMio="
          "cache.flakehub.com-5:zB96CRlL7tiPtzA9/WKyPkp3A2vqxqgdgyTVNGShPDU="
          "cache.flakehub.com-6:W4EGFwAGgBj3he7c5fNh9NkOXw0PUVaxygCVKeuvaqU="
          "cache.flakehub.com-7:mvxJ2DZVHn/kRxlIaxYNMuDG1OvMckZu32um1TadOR8="
          "cache.flakehub.com-8:moO+OVS0mnTjBTcOUh2kYLQEd59ExzyoW1QgQ8XAARQ="
          "cache.flakehub.com-9:wChaSeTI6TeCuV/Sg2513ZIM9i0qJaYsF+lZCXg0J6o="
          "cache.flakehub.com-10:2GqeNlIp6AKp4EF2MVbE1kBOp9iBSyo0UPR9KoR0o1Y="
        ];
        trusted-substituters = [
          "https://cache.nixos.org"
          "https://colemickens.cachix.org"
          "https://nix-community.cachix.org"
          "https://cosmic.cachix.org"
          "https://cache.flakehub.com"
        ];
        substituters = trusted-substituters;
        trusted-users = [
          "@wheel"
          "cole"
          "root"
        ];
      };
      extraOptions = ''
        experimental-features = nix-command flakes
        !include ${config.sops.secrets.nix-access-tokens.path}
      '';
    };
  };
}
