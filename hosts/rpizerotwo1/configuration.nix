{ config, inputs, pkgs, lib, ... }:

let
  _networks = {
    "10-eth0".addresses = [{
      addressConfig = {
        Address = "192.168.210.132/16"; # in nixos
      };
    }];
  };
in
{
  imports = [
    ../rpi-tmpl-zerotwow.nix

    # IMPORTER PICKS ONE:
    # ../../mixins/netboot-client.nix
    ../rpi-sdcard.nix
  ];
  config = {
    networking.hostName = "rpizerotwo1";
    system.stateVersion = "21.11";
    system.build = rec {
      sbc_serial = "43eac8d6";
      sbc_mac = "ff-bb-cc-cc-bb-ff";
      sbc_ubootid = "01-${sbc_mac}";
      mbr_disk_id = "99999021";
    };
    boot.initrd.systemd.network.networks = _networks;
    systemd.network.networks = _networks;
  };
}
