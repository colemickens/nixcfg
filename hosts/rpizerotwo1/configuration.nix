{ config, inputs, pkgs, lib, ... }:

let
  eth_ip = "192.168.133.221/16";
in
{
  imports = [
    ../rpi-tmpl-zerotwow.nix

    # IMPORTER PICKS ONE:
    # ../mixins/netboot-client.nix
    ../rpi-sdcard.nix
  ];
  config = {
    networking.hostName = "rpizerotwo1";
    system.stateVersion = "21.11";
    system.build = rec {
      pi_serial = "43eac8d6";
      pi_mac = "ff-bb-cc-cc-bb-ff";
      pi_ubootid = "01-${pi_mac}";
      mbr_disk_id = "99999021";
    };
    # boot.initrd.systemd.network.networks."10-eth0".addresses =
    #   [{ addressConfig = { Address = eth_ip; }; }];
  };
}
