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
    ./rpi-towboot.nix
  ];

  config = {
    nixcfg.common.useZfs = false;
    environment.systemPackages = with pkgs; [ picocom ];
    hardware.usbWwan.enable = true;

    tow-boot.config = {
      rpi = {
        upstream_kernel = true;

        disable_fw_kms_setup = lib.mkDefault true;
        hdmi_ignore_cec = lib.mkDefault true;
        hdmi_ignore_cec_init = lib.mkDefault true;
        initial_boost = lib.mkDefault 60;
        force_turbo = lib.mkDefault true; # maybe helps living room tv
      };
    };

    boot = {
      # loader.generic-extlinux-compatible.useGenerationDeviceTree = false;
      initrd.kernelModules = config.boot.initrd.availableKernelModules;
      kernelPackages = pkgs.linuxPackages_latest;
      kernelParams = [
        "cma=128M"
        "console=tty1"
      ];
      initrd.availableKernelModules = [
        # "genet" # netboot, does this even make sense?
        # "nvme" # boot-nvme
        "pcie_brcmstb" # boot-usb
        "broadcom" # netboot, does this even make sense?
        "vc4"
        "v3d" # vc4/hdmi stuffs?
      ];
      # mainline + generation tree
      # = raw hdmi audio device, so blacklist snd_bcm2835
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
