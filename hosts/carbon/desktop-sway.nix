{ config, pkgs, lib, inputs, ... }:

{
  imports = [
    ../../profiles/sway/default.nix
  ];

  config = {
    home-manager.users.cole = { pkgs, ... }: {
      services = {
        udiskie.enable = false;
        kanshi = {
          enable = true;
          systemdTarget = "graphical-session.target";
          profiles = {
            "docked".outputs = [
              { criteria = "eDP-1"; status = "disable"; }
              { criteria = "DP-5"; position = "0,0"; }
              # { criteria = out_carbon; status = "disable"; }
              # { criteria = out_aw3418dw; position = "1920,0"; }
              # { criteria = out_aw2521h; position = "0,0"; }
            ];
          };
        };
      };
    };
  };
}
