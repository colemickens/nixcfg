{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs = {
        carapace = {
          enable = true;
          # TODO: causes error
          # TODO: manually enable in my own config
          # enableNushellIntegration = true;
        };
      };
    };
  };
}
