{ config, pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {  
      programs.zellij = {
        enable = true;

        settings = {
          default-mode = "normal";
          default-shell = "nu"; # TODO SET GLOBALLY?
          simplified-ui = true;
        };
      };
    };
  };
}
