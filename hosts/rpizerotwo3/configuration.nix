{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpizerotwo3";
  mbr_disk_id = "99999023";
in
{
  imports = [
    ../rpizerotwo1/configuration.nix
  ];

  config = {
    system.build.mbr_disk_id = lib.mkForce mbr_disk_id;
    networking.hostName = lib.mkForce hn;
  };
}
