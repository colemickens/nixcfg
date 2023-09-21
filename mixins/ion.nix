{ config, pkgs, ... }:

{
  # settings are largely derived from:
  # https://github.com/nushell/nushell/blob/main/docs/sample_config/config.toml
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.ion = {
        enable = (pkgs.hostPlatform.system == "x86_64-linux"); # idk
      };
    };
  };
}
