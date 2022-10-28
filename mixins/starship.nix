{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.starship = {
        enable = true;
        enableZshIntegration = false;
        enableIonIntegration = false;
        enableBashIntegration = false;
        settings = {
          add_newline = true;
          hostname = {
            ssh_only = false;
          };
          shell = {
            disabled = false;
          };
        };
      };
    };
  };
}
