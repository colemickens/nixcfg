{ config, pkgs, lib, ... }:

with lib;
let
  cfg = config.kexec.justdoit;
  x = if cfg.nvme then "p" else "";
in {
  
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
}
