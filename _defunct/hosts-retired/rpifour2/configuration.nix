{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

let
  eth_ip = "192.168.133.202/16";
  # <rpifour2>
  child = "rpizerotwo1";
  rpi-inst-child = import ../rpi-inst.nix {
    inherit pkgs;
    tconfig = inputs.self.nixosConfigurations.${child}.config;
  };
  # </rpifour2>
in
{
  imports = [
    ../rpi-tmpl-four.nix
  ];
  config = {
    networking.hostName = "rpifour2";
    system.stateVersion = "21.11";
    boot.initrd.systemd.network.networks."10-eth0".addresses =
      [{ addressConfig = { Address = eth_ip; }; }];
    system.build = rec {
      sbc_serial = "156b6214";
      sbc_mac = "dc-a6-32-59-d6-f8";
      sbc_ubootid = "01-${pi_mac}";
      mbr_disk_id = "99999942";
    };
    
    # <rpifour2>
    environment.systemPackages = with pkgs; [
      rpi-inst-child
    ];
    # </rpifour2>
  };
}
