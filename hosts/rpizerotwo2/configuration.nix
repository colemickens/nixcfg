{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  _networks = {
    "10-eth0".addresses = [{
      addressConfig = {
        Address = "192.168.207.40/16"; # in nixos
      };
    }];
  };
in
{
  imports = [
    ../rpi-tmpl-zerotwow.nix

    # IMPORTER PICKS ONE:
    ../../mixins/netboot-client.nix
    # ../rpi-sdcard.nix
  ];
  config = {
    networking.hostName = "rpizerotwo2";
    system.stateVersion = "21.11";
    system.build = rec {
      sbc_serial = "73314592";
      sbc_mac = "ff-dd-ee-dd-ee-ff";
      sbc_ubootid = "01-${sbc_mac}";
      mbr_disk_id = "99999022";
    };
    boot.initrd.systemd.network.networks = _networks;
    systemd.network.networks = _networks;
  };
}
