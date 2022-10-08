{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        cachix
      ];
    };

    sops.secrets."cachix.dhall" = {
      owner = "cole";
      group = "cole";
      path = "/home/cole/.config/cachix/cachix.dhall";
    };
    sops.secrets."cachix_authtoken_colemickens" = {
      owner = "cole";
      group = "cole";
    };
    sops.secrets."cachix_signkey_colemickens" = {
      owner = "cole";
      group = "cole";
    };
  };
}
