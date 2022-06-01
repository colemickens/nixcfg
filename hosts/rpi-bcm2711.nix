{ pkgs, lib, modulesPath, inputs, config, ... }:

# from: https://www.raspberrypi.com/documentation/computers/processors.html
#   This is the Broadcom chip used in the Raspberry Pi 4 Model B, the Raspberry
#   Pi 400, and the Raspberry Pi Compute Module 4. The architecture of the
#   BCM2711 is a considerable upgrade on that used by the SoCs in earlier
#   Raspberry Pi models. It continues the quad-core CPU design of the BCM2837,
#   but uses the more powerful ARM A72 core.

## RPI4

let
  upstream_kernel = false;
  # upstream_kernel = true;
  mbr_disk_id = config.system.build.mbr_disk_id;
in {
  imports = [
    ./rpi-core.nix
    ./rpi-towboot.nix
  ] ++ (if upstream_kernel then [] else [
    ./rpi-foundation-v3d.nix
  ]);

  # NOTES: rpi4-specific:
  # sudo env \
  #   BOOTFS=/boot/firmware \
  #   FIRMWARE_RELEASE_STATUS=stable \
  #     rpi-eeprom-config --edit
  #

  config = {
    environment.systemPackages = with pkgs; [
      picocom
      libraspberrypi
    ];
    hardware.usbWwan.enable = true;

    tow-boot.config = {
      rpi = {
        upstream_kernel = upstream_kernel;

        arm_boost = true;
        initial_boost = 60;
        hdmi_enable_4kp60 = true;
        hdmi_ignore_cec = true;
        disable_fw_kms_setup = upstream_kernel;
        
        enable_watchdog = true;
      };
    };

    boot = {
      loader.generic-extlinux-compatible.useGenerationDeviceTree = true;

      kernelPackages = if upstream_kernel
        then lib.mkForce pkgs.linuxPackages_latest #vc4/hdmi might be broken on 5.18
        else lib.mkForce pkgs.linuxPackages_rpi4; #vc4/hdmi might be broken on 5.18

      kernelParams = ([
        "cma=512M"
        "snd_bcm2835.enable_hdmi=1"
        "snd_bcm2835.enable_headphones=0"
      ] ++ (if upstream_kernel then [
        # "console=ttyS0,115200" "console=tty1" # no output after "starting kernel"
        "console=serial0,115200" "console=tty1"
      ] else [
        # I don't think we have the DT enablement for uart serial
      ]));
      # initrd.preFailCommands = ''
      #   reboot
      # '';
      initrd.kernelModules = config.boot.initrd.availableKernelModules;
      initrd.availableKernelModules = [
        # "genet" # netboot, does this even make sense?
        # "nvme" # boot-nvme
        "pcie_brcmstb" # boot-usb
        "broadcom" # netboot, does this even make sense?
        "v3d" "vc4" # vc4/hdmi stuffs?
        "reset_raspberrypi" # needed for USB reset, so that USB works in kernel 5.14
        "xhci_pci" # boot-usb
        "uas" # boot-usb-uas
        "usb_storage" # boot-usb
        "sd_mod" # boot-usb
        "mmc_block" # boot-sdcard
        "usbhid" # luks/kb
        "hid_generic" # luks/kb
        "hid_microsoft" # luks/kb
      ];
      # unblakc-listing this fixed hdmi audio with `fkms`...
      blacklistedKernelModules = if upstream_kernel then [ "snd_bcm2835" ] else [];
    };

    # TODO: harmonize filesystems (rpifour1,sinkor), move them here??
    fileSystems = lib.mkDefault {
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
    swapDevices = lib.mkDefault [{
      device = "/dev/disk/by-partuuid/${mbr_disk_id}-04";
    }];
  };
}
