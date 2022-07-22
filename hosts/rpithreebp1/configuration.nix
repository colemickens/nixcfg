{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

let
  eth_ip = "192.168.218.140/16";
in
{
  imports = [
    ../rpi-tmpl-threebp.nix
  ];
  config = {
    networking.hostName = "rpithreebp1";
    system.stateVersion = "21.11";
    boot.initrd.systemd.network.networks."10-eth0".addresses =
      [{ addressConfig = { Address = eth_ip; }; }];
    system.build = rec {
      pi_serial = "e25c7db6";
      pi_mac = "b8-27-eb-5c-7d-b6";
      pi_ubootid = "01-${pi_mac}";
      mbr_disk_id = "999993b1";
    };
  };
}
