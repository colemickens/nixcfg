{ config, pkgs, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.htop = {
        enable = true;
        settings = {
          show_program_path = false;
        };
      };
    };
  };
}
