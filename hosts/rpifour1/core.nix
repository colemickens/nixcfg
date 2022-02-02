{ pkgs, modulesPath, inputs, config, ... }:
let
  hostname = "rpifour1";
in
{
  imports = [
    ../../mixins/common.nix
    ../../profiles/user.nix

    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
  ];

  #
  # sudo env BOOTFS=/boot/firmware FIRMWARE_RELEASE_STATUS=stable rpi-eeprom-config --edit
  #

  config = {
    # ZFS
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        fsType = "vfat";
        options = [ "nofail" ];
      };
      "/boot/firmware" = {
        # the fucking dev name changes depending on how I boot (likely due to diffs in DTBs/bootloader-dtb-loading)
        device = "/dev/disk/by-partuuid/ce8f2026-17b1-4b5b-88f3-3e239f8bd3d8";
        fsType = "vfat";
        options = [ "nofail" "ro" ];
      };
      "/" = {
        device = "tank/root";
        fsType = "zfs";
      };
      "/nix" = {
        device = "tank/nix";
        fsType = "zfs";
      };
    };

    system.stateVersion = "21.05";

    nix.nixPath = [];
    nix.gc.automatic = true;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
      libraspberrypi
      cachix

      minicom
      screen
      ncdu
      binutils
    ];

    nixpkgs.config.allowBroken = true;
    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelPackages = null;

      initrd.availableKernelModules = [
        "pcie_brcmstb" "bcm_phy_lib" "broadcom" "mdio_bcm_unimac" "genet"
        "vc4" "bcm2835_dma" "i2c_bcm2835"
        "reset_raspberrypi" # needed for USB reset, so that USB works in kernel 5.14
        "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"
        "uas" # necessary for my UAS-enabled NVME-USB adapter
      ];
      kernelModules = config.boot.initrd.availableKernelModules;

      initrd.supportedFilesystems = [ "zfs" ];
      supportedFilesystems = [ "zfs" ];
    };

    networking = {
      hostId = "deadb00f";
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
      wireless.enable = false;
      wireless.iwd.enable = false;
      interfaces."eth0".ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 16;
      }];
      defaultGateway = "192.168.1.1";
      nameservers = [ "192.168.1.1" ];
    };
    services.timesyncd.enable = true;
    time.timeZone = "America/Los_Angeles";

    nixpkgs.config.allowUnfree = true;
    hardware = {
      # this pulls in firmware-nonfree which clashes with raspberrypiWirelessFirmware
      # TODO: why does this even clash? Shouldn't the rpiWifiFw package supply the FW for *only* those devices?
      enableRedistributableFirmware = false;
    };
  };
}
