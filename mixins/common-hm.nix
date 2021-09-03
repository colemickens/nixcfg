{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.extraOutputsToInstall = [ "info" "man" "share" "icons" "doc" ];
    };
  };
}
