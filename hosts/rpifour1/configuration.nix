{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

let
  hn = "rpifour1";
  eth_ip = "192.168.100.41/16";
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
      pi_serial = "e43b854b";
      pi_mac = "dc-a6-32-47-73-14";
      pi_ubootid = "01-${pi_mac}";
      mbr_disk_id = "99999941";
    };
  };
}
