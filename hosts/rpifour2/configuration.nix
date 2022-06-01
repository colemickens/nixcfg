{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpifour2";
  mbr_disk_id = "99999942";
  static_ip = "192.168.1.30/16";
in
{
  imports = [
    ../rpi-bcm2711.nix
    ../../profiles/viz
    ../../mixins/gfx-rpi.nix
    ../../mixins/wpa-full.nix
  ];

  config = {
    networking.hostName = hn;
    system.stateVersion = "21.11";
    system.build.mbr_disk_id = mbr_disk_id;

    systemd.network = {
      networks."20-eth0-static-ip" = {
        matchConfig.Driver = "r8152";
        addresses = [{ addressConfig = { Address = static_ip; }; }];
        networkConfig = {
          Gateway = "192.168.1.1";
          DNS = "192.168.1.1";
          DHCP = "ipv6";
        };
      };
      networks."05-block-wlan" = {
        matchConfig.Type = "wlan";
        networkConfig = { };
        linkConfig.Unmanaged = "yes";
        linkConfig.RequiredForOnline = false;
      };
    };

    fileSystems = {
      "/" = { fsType = "ext4"; device = "/dev/disk/by-partlable/${hn}-root-ext4"; };

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
    swapDevices = [{ device = "/dev/disk/by-partlabel/${hn}-swap"; }];
  };
}
