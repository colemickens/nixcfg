{ config, pkgs, lib, inputs, modulesPath, ... }:

let
  ndhSocket = "/var/run/ndh.sock";
in {
  config = {
    systemd.services.nix-daemon-hydra = {
      # do the bind mount for /nix/store
      # copy the rest of the service from upstream
      
    };

    services.hydra-dev = {
      extraEnv = {
        NIX_REMOTE = ;
      };
    };
  };
}
