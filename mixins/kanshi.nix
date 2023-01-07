{ pkgs, lib, config, inputs, ... }:

let
  out_aw3418dw = "Dell Inc. Dell AW3418DW #ASPD8psOnhPd";
  out_aw2521h = "Dell Inc. Dell AW2521H #HLAYMxgwABDZ";
  out_carbon = "SDC 0x4152 Unknown";
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
            "carbon_undocked".outputs = [
              { criteria = out_carbon; status = "enable"; }
            ];
            "carbon_docked_aw25".outputs = [
              { criteria = out_carbon; status = "disable"; }
              { criteria = out_aw2521h; position = "0,0"; }
            ];
            "carbon_docked_aw34".outputs = [
              { criteria = out_carbon; status = "disable"; }
              { criteria = out_aw3418dw; position = "0,0"; }
            ];
            "carbon_docked_both".outputs = [
              { criteria = out_carbon; status = "disable"; }
              { criteria = out_aw3418dw; position = "1920,0"; }
              { criteria = out_aw2521h; position = "0,0"; }
            ];
            "zeph_docked_aw34".outputs = [
              { criteria = out_zeph; status = "disable"; }
              { criteria = out_aw3418dw; position = "0,0"; }
            ];
          };
        };
      };
    };
  };
}
