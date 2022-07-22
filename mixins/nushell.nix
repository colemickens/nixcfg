{ config, pkgs, ... }:

{
  # settings are largely derived from:
  # https://github.com/nushell/nushell/blob/main/docs/sample_config/config.toml
  config = {
    home-manager.users.cole = { pkgs, ... }: {  
      programs.nushell = {
        #enable = (pkgs.system == "x86_64-linux" || pkgs.system == "aarch64-linux");
        enable = true;
        configFile.source = ./nushell.config.nu;
        envFile.source = ./nushell.env.nu;
      };
    };
  };
}
