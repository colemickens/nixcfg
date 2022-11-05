{ config, pkgs, ... }:

let
  host_color = config.nixcfg.common.hostColor;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.nushell = {
        enable = true;
        
        envFile.source = (pkgs.substituteAll {
          src = ./nushell-env.nu;
          inherit host_color;
        });
        configFile.source = ./nushell-config.nu;
      };
    };
  };
}
