{ config, pkgs, lib, inputs, ... }:
let
  hostname = "xeep";
in
{
  imports = [
    ../../profiles/interactive.nix

    # ../../mixins/bolt.nix # thunderbolt controller is probably busted
    ../../mixins/grub-signed-shim.nix
    ../../mixins/hidpi.nix
    ../../mixins/logitech-mouse.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    ../../mixins/samba.nix
    ../../mixins/syncthing.nix
    ../../mixins/wpasupplicant.nix
    ../../mixins/zfs.nix

    ../../mixins/rclone-googledrive-mounts.nix

    ./services/aria2.nix
    ./services/revproxy.nix
    ./services/home-assistant
    ./services/plex.nix
    ./services/unifi.nix

    ../../mixins/gfx-intel.nix # TODO: nixosHardware?
    inputs.hardware.nixosModules.dell-xps-13-9370

    ./unfree.nix
  ];

  config = {
    system.stateVersion = "21.05";

    networking.hostName = hostname;
    hardware.cpu.intel.updateMicrocode = true;
    services.fwupd.enable = true;
    services.tlp.enable = lib.mkForce false; # does this come frm nixosHardware?

    boot = {
      initrd.availableKernelModules = [
        "xhci_pci"
        "xhci_hcd" # usb
        "nvme"
        "usb_storage"
        "sd_mod" # nvme / external usb storage
        "rtsx_pci_sdmmc" # sdcard
        "intel_agp"
        "i915" # intel integrated graphics
        "usbnet"
        "r8152" # usb ethernet adapter
        "msr"
      ];
      kernelModules = config.boot.initrd.availableKernelModules;
      initrd.luks.devices = {
        root = {
          name = "root";
          device = "/dev/disk/by-partlabel/newluks";
          preLVM = true;
          allowDiscards = true;

          keyFileSize = 4096;
          keyFile = "/dev/disk/by-id/mmc-EB1QT_0xa5f25355";
          fallbackToPassword = true;
        };
      };
    };

    fileSystems = {
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/newboot"; };
      "/" = { fsType = "zfs"; device = "tank2/root"; };
      "/home" = { fsType = "zfs"; device = "tank2/home"; };
      "/nix" = { fsType = "zfs"; device = "tank2/nix2"; };
    };
    swapDevices = [ ];
  };
}
