{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  eth_ip = "192.168.133.223";
in
{
  imports = [
    ../rpi-tmpl-zerotwow.nix

    # IMPORTER PICKS ONE:
    # ../mixins/netboot-client.nix
    ../rpi-sdcard.nix
  ];
  config = {
    networking.hostName = "rpizerotwo3";
    system.stateVersion = "21.11";
    system.build = rec {
      pi_serial = "xxxxxxxx";
      pi_mac = "aa-bb-cc-dd-ee-ff";
      pi_ubootid = "01-${pi_mac}";
      mbr_disk_id = "99999023";
    };
    # boot.initrd.systemd.network.networks."10-eth0".addresses =
    #   [{ addressConfig = { Address = eth_ip; }; }];
  };
}
