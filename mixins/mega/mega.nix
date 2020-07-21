{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.file.".megarc".source = ./megarc;
    };
  };
}
