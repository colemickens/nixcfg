{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

let
  eth_ip = "192.168.162.69/16";
in
{
  imports = [
    ../rpi-tmpl-four.nix
    ../../mixins/netboot-client.nix
  ];
  config = {
    networking.hostName = "rpifour1";
    system.stateVersion = "21.11";
    boot.initrd.systemd.network.networks."10-eth0".addresses =
      [{ addressConfig = { Address = eth_ip; }; }];
    system.build = rec {
      sbc_serial = "e43b854b";
      sbc_mac = "dc-a6-32-47-73-14";
      sbc_ubootid = "01-${sbc_mac}";
      mbr_disk_id = "99999941";
    };
  };
}
