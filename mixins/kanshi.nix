{ pkgs, lib, config, inputs, ... }:

let
  out_aw3418dw = "Dell Inc. Dell AW3418DW #ASPD8psOnhPd";
  out_aw2521h = "Dell Inc. Dell AW2521H #HLAYMxgwABDZ";
  out_zeph = "Thermotrex Corporation TL140ADXP01 Unknown";
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      services = {
        kanshi = {
          enable = true;
          systemdTarget = "graphical-session.target";
          profiles = {
            "zeph_undocked".outputs = [
              { criteria = out_zeph; status = "enable"; scale = 1.7; adaptive_sync = "enable"; }
            ];
            "zeph_docked_aw34".outputs = [
              { criteria = out_zeph; status = "disable"; }
              { criteria = out_aw3418dw; position = "1920,0"; mode = "3440x1440@120Hz"; adaptive_sync = "enable"; }
              { criteria = out_aw2521h; position = "0,0"; mode = "1920x1080@240Hz"; adaptive_sync = "enable"; }
            ];
          };
        };
      };
    };
  };
}
