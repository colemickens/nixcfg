{ config, lib, pkgs, inputs, options, ... }:

{
  config = {
    ###################################
    ## DEBLOAT
    ###################################
    documentation = (lib.mkIf cfg.defaultNoDocs ({
      enable = false;
      doc.enable = false;
      man.enable = true;
      info.enable = false;
      nixos.enable = false;
    }));

    services.journald.extraConfig = ''
      SystemMaxUse=10M
    '';
  };
}

