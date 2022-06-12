{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

let
  hn = "rpifour2";
  eth_ip = "192.168.133.201/16";
in
{
  imports = [
    ../rpi-tmpl-four.nix
  ];
  config = {
    networking.hostName = hn;
    system.stateVersion = "21.11";
    boot.initrd.systemd.network.networks."10-eth0".addresses =
      [{ addressConfig = { Address = eth_ip; }; }];
    system.build = rec {
      pi_serial = "156b6214";
      pi_mac = "dc-a6-32-59-d6-f8";
      pi_ubootid = "01-${pi_mac}";
      mbr_disk_id = "99999942";
    };
  };
}
