{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

let
  eth_ip = "192.168.218.140/16";
in
{
  imports = [
    ../rpi-tmpl-threebp.nix
    ../../mixins/netboot-client.nix
  ];
  config = {
    networking.hostName = "rpithreebp1";
    system.stateVersion = "21.11";
    boot.initrd.systemd.network.networks."10-eth0".addresses =
      [{ addressConfig = { Address = eth_ip; }; }];
    system.build = rec {
      sbc_serial = "e25c7db6";
      sbc_mac = "b8-27-eb-5c-7d-b6";
      sbc_ubootid = "01-${sbc_mac}";
      mbr_disk_id = "999993b1";
    };
  };
}
