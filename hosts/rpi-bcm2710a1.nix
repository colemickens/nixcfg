{ pkgs, lib, modulesPath, inputs, config, ... }:

# from: https://www.raspberrypi.com/documentation/computers/processors.html
#   The Raspberry Pi RP3A0 is our first System-in-Package (SiP) consisting of a
#   Broadcom BCM2710A1 — which is the silicon die packaged inside the Broadcom
#   BCM2837 chip which is used on the Raspberry Pi 3 — along with 512 MB of DRAM.

## RPI3+
## RPI02W

let
  mbr_disk_id = config.system.build.mbr_disk_id;
in
{
  imports = [
    ./rpi-core.nix
  ];

  config = {
    nixcfg.common.useZfs = false;

    boot = {
      loader.generic-extlinux-compatible.useGenerationDeviceTree = false;
      initrd.kernelModules = [ "vc4" ];
      blacklistedKernelModules = [ "bcm_snd2835" ];
    };

    # YAY: we have unified filesystems across devices, good job!
    fileSystems = {
      "/" = {
        device = "/dev/disk/by-partuuid/${mbr_disk_id}-03";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-partuuid/${mbr_disk_id}-02";
        fsType = "vfat";
      };
      "/boot/firmware" = {
        device = "/dev/disk/by-partuuid/${mbr_disk_id}-01";
        fsType = "vfat";
        options = [ "ro" "nofail" ];
      };
    };
    swapDevices = [{
      device = "/dev/disk/by-partuuid/${mbr_disk_id}-04";
    }];
  };
}
