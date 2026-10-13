{ config, ... }:

{
  config = {
    home-manager.users.cole =
      { pkgs, lib, ... }:
      {
        programs.ssh = {
          enable = true;
          enableDefaultConfig = false;
        };
      };
  };
}
