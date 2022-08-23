{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  _networks = {
    "10-eth0".addresses = [{
      addressConfig = {
        Address = "192.168.125.159/16"; # gigabit eth + adapter
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
    # ../mixins/wpa-full.nix
  ];
  config = {
    networking.hostName = "rpizerotwo2";
    system.stateVersion = "22.05";
    system.build = rec {
      # uboot also looks for: C0A8CF28 ?
      # uboot with eth adapter = C0A87D9F
      sbc_serial = "73314592";
      sbc_mac = "a0-ce-c8-57-fb-07";
      sbc_ubootid = "01-${sbc_mac}";
      mbr_disk_id = "99999022";
    };
    boot.initrd.systemd.network.networks = _networks;
    networking.useNetworkd = true;
    networking.wireless.iwd.enable = true;
    systemd.network.networks = _networks;
  };
}
