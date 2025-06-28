{ ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ cachix ];
      };

    sops.secrets."cachix.dhall" = {
      owner = "cole";
      group = "cole";
      path = "/home/cole/.config/cachix/cachix.dhall";
      sopsFile = ../secrets/encrypted/cachix.dhall;
      format = "binary";
    };
    # sops.secrets."cachix_authtoken_colemickens" = {
    #   owner = "cole";
    #   group = "cole";
    #   sopsFile = ../secrets/encrypted/cachix_authtoken_colemickens;
    #   format = "binary";
    # };
    # sops.secrets."cachix_signkey_colemickens" = {
    #   owner = "cole";
    #   group = "cole";
    #   sopsFile = ../secrets/encrypted/cachix_signkey_colemickens;
    #   format = "binary";
    # };
  };
}
