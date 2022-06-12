{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpizerotwo3";
  eth_ip = "192.168.100.023";
in
{
  imports = [
    ../rpi-tmpl-zerotwow.nix
  ];
  config = {
    networking.hostName = hn;
    system.stateVersion = "21.11";
    boot.initrd.systemd.network.networks."10-eth0".addresses =
      [{ addressConfig = { Address = eth_ip; }; }];
    system.build = rec {
      pi_serial = "xxxxxxxx";
      pi_mac = "aa-bb-cc-dd-ee-ff";
      pi_ubootid = "01-${pi_mac}";
      mbr_disk_id = "99999023";
    };
  };
}
