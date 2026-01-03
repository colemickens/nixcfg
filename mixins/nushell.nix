{ config, pkgs, lib, ... }:

let
  host_color = config.nixcfg.common.hostColor;
in
{
  config = {
    home-manager.users.cole =
      { pkgs, ... }@hm:
      {
        programs.nushell.configFile.text = lib.concatStrings [
          "let host_color = \"${host_color}\""
          (builtins.readFile ./nushell-config.nu)
        ];

        programs.nushell = {
          enable = true;
        };
      };
  };
}
