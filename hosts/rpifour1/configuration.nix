{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpifour1";
  mbr_disk_id = "99999941";
  static_ip = "192.168.1.20/16";

  _inst = target: pkgs.callPackage ../rpi-inst.nix {
    inherit pkgs inputs target;
    inherit (inputs) tow-boot;
    tconfig = inputs.self.nixosConfigurations.${target}.config;
  };
in
{
  imports = [
    ../rpi-bcm2711.nix
    ../../profiles/interactive.nix # common + interactive
    ../../mixins/pipewire.nix # snapcast
    ../../mixins/snapclient-local.nix # snapcast
    ../../mixins/zfs.nix
  ];

  config = {
    networking.hostName = hn;
    system.stateVersion = "21.05";
    system.build.mbr_disk_id = mbr_disk_id;
      
    nixcfg.common.useZfs = false;

    # environment.systemPackages = [
    #   (_inst "rpithreebp1")
    #   (_inst "rpizerotwo1")
    # ];

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
      networks."15-block-wlan" = {
        matchConfig.Name = "wlan0";
        networkConfig = { };
        linkConfig.Unmanaged = "yes";
      };
    };

    fileSystems = {
      # "/" = {
      #   fsType = "zfs";
      #   device = "tank/root";
      # };
      # "/nix" = {
      #   fsType = "zfs";
      #   device = "tank/nix";
      # };
      "/" = {
        fsType = "xfs";
        device = "/dev/disk/by-partlabel/${hn}-root";
      };
      "/boot" = {
        fsType = "vfat";
        # device = "/dev/disk/by-partlabel/${hn}-boot";
        device = "/dev/disk/by-partuuuid/${mbr_disk_id}-02";
        options = [ "nofail" ];
      };
      "/boot/firmware" = {
        fsType = "vfat";
        # device = "/dev/disk/by-label/TOW-BOOT-FI";
        device = "/dev/disk/by-partuuuid/${mbr_disk_id}-01";
        options = [ "nofail" "ro" ];
      };
    };
  };
}
