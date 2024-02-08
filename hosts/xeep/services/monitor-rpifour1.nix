{
  config,
  pkgs,
  lib,
  modulesPath,
  inputs,
  ...
}:

let
in
{
  config = {
    systemd.services."justdoit-auto" = {
      # disable basically all sandboxing for this service
      path = [
        pkgs.util-linux
        config.system.build.justdoit
      ];

      script = ''
        if blkid | grep "NIXOS"; then
            exit 0
        else
            justdoit
        fi
      '';
    };
  };
}
