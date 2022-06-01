{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpifour1";
  mbr_disk_id = "99999941";
  static_ip = "192.168.1.20/16";

  _inst = d: import ../rpi-inst.nix {
    inherit pkgs;
    tconfig = inputs.self.nixosConfigurations.${d}.config;
  };
in
{
  imports = [
    ../rpi-bcm2711.nix
    ../../profiles/viz
    ../../mixins/gfx-rpi.nix
    ../../mixins/wpa-full.nix
  ];

  config = {
    networking.hostName = lib.mkForce hn;
    system.stateVersion = "21.11";
    system.build.mbr_disk_id = lib.mkForce mbr_disk_id;
      
    nixcfg.common.useZfs = false;

    environment.systemPackages = [
      (_inst "rpizerotwo1")
      # (_inst "rpizerotwo2")
    ];

    systemd.network = {
      networks."20-eth0-static-ip" = lib.mkForce {
        matchConfig.Driver = "r8152";
        addresses = [{ addressConfig = { Address = static_ip; }; }];
        networkConfig = {
          Gateway = "192.168.1.1";
          DNS = "192.168.1.1";
          DHCP = "ipv6";
        };
      };
      networks."05-block-wlan" = lib.mkForce {
        matchConfig.Type = "wlan";
        networkConfig = { };
        linkConfig.Unmanaged = "yes";
        linkConfig.RequiredForOnline = false;
      };
    };

    # rpifour1 breaks the rules (usb-ssd/zsh,etc)
    fileSystems = lib.mkForce {
      "/" = { fsType = "ext4"; device = "/dev/disk/by-partlabel/${hn}-root-ext4"; };
      # "/" = { fsType = "zfs"; device = "${hn}pool/root"; };
      # "/nix" = { fsType = "zfs"; device = "${hn}pool/nix"; };
      # "/home" = { fsType = "zfs"; device = "${hn}pool/home"; };
      # "/persist" = { fsType = "zfs"; device = "${hn}pool/persist"; };

      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${hn}-boot";
        # device = "/dev/disk/by-partuuid/${mbr_disk_id}-02";
        options = [ "nofail" ];
      };
      "/boot/firmware" = {
        fsType = "vfat";
        # device = "/dev/disk/by-label/TOW-BOOT-FI";
        device = "/dev/disk/by-partuuid/${mbr_disk_id}-01";
        options = [ "nofail" "ro" ];
      };
    };
    swapDevices = lib.mkForce [{
      device = "/dev/disk/by-partlabel/${hn}-swap";
    }];
  };
}
