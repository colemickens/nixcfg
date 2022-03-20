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
  };
}
