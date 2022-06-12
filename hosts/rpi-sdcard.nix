{ pkgs, lib, modulesPath, inputs, config, ... }:

{
  config = {
    fileSystems = {
      "/" = {
        fsType = "ext4";
        # device = "/dev/disk/by-partlabel/${hn}-root-ext4";
        device = "/dev/disk/by-partuuid/${config.system.build.mbr_disk_id}-03";
      };

      "/boot" = {
        fsType = "vfat";
        # device = "/dev/disk/by-partlabel/${hn}-boot";
        device = "/dev/disk/by-partuuid/${config.system.build.mbr_disk_id}-02";
        options = [ "nofail" ];
      };
      "/boot/firmware" = {
        fsType = "vfat";
        device = "/dev/disk/by-partuuid/${config.system.build.mbr_disk_id}-01";
        options = [ "nofail" "ro" ];
      };
    };
    swapDevices = [{ device = "/dev/disk/by-partlabel/${config.networking.hostName}-swap"; }];
  };
}
