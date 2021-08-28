{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "sinkor";
in
{
  imports = [
    ../../modules/loginctl-linger.nix

    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/common.nix
    ../../mixins/sshd.nix

    ../../profiles/user.nix
  ];

  config = {
    system.stateVersion = "21.03";
    users.users.cole.linger = true;

    nix.nixPath = [];
    nix.gc.automatic = true;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
    ];

    boot = {
      # sinkor uses Tow-Boot so we can pretend this is a conventional UEFI machine
      boot.loader.systemd-boot = {
        enable = true;
        configurationLimit = 5;
      };

      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;

      initrd.availableKernelModules = [
        "pcie_brcmstb" "bcm_phy_lib" "broadcom" "mdio_bcm_unimac" "genet"
        "vc4" "bcm2835_dma" "i2c_bcm2835"
        "xhci_pci" "nvme" "usb_storage" "sd_mod"
        "uas" # necessary for my UAS-enabled NVME-USB adapter
      ];
      kernelModules = config.boot.initrd.availableKernelModules;

      initrd.supportedFilesystems = [ "zfs" ];
      supportedFilesystems = [ "zfs" ];
    };

    networking = {
      hostId = "deadbead";
      hostName = hostname;
      firewall.enable = true;
      networkmanager.enable = true;
      wireless.enable = false;
      wireless.iwd.enable = false;
      useDHCP = false;
    };
    time.timeZone = "America/Chicago";

    nixpkgs.config.allowUnfree = true;
    hardware = {
      enableRedistributableFirmware = true;
    };

    # TODO: declarative wifi for Mickens + MickPetrey wifi networks

    # ZFS
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        fsType = "vfat";
        options = [ "nofail" ];
      };
      "/" = {
        # TODO: should we snapshot and revert this on boot, like grahamc's darlings?
        device = "tank/root";
        fsType = "zfs";
      };
      "/nix" = {
        device = "tank/nix";
        fsType = "zfs";
      };
      # TODO: configure this to backup to rsync.net
      # sudo zfs create -o mountpoint=none tank/var
      "/home/cole/syncthing_data" = {
        # sudo zfs create -o mountpoint=legacy tank/var/unifi
        device = "tank/var/syncthing_data";
        fsType = "zfs";
      };
    };
  };
}
