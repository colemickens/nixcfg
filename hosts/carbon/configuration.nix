{ config, pkgs, lib, inputs, ... }:

let
  hn = "carbon";
in
{
  imports = [
    # ../../profiles/gui-wayland-sway.nix
    ../../profiles/gui-wayland-hyprland.nix
    ../../profiles/addon-dev.nix
    ../../profiles/addon-laptop.nix
    ../../profiles/addon-gaming.nix

    ../../mixins/gfx-radeonsi.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/addon-fixes.nix

    ../../mixins/android.nix
    ../../mixins/easyeffects.nix
    ../../mixins/hidpi.nix
    ../../mixins/ledger.nix
    ../../mixins/libvirt.nix
    ../../mixins/syncthing.nix
    ../../mixins/zfs.nix

    # ./experimental.nix
    ./unfree.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  config = {
    system.stateVersion = "21.05";
    networking.hostName = hn;
    nixcfg.common.hostColor = "purple";
    nixcfg.common.skipMitigations = false;

    time.timeZone = lib.mkForce null; # we're on the move
    services.tailscale.useRoutingFeatures = "client";
    hardware.video.hidpi.enable = true;

    fileSystems = {
      "/efi" = { fsType = "vfat"; device = "/dev/nvme0n1p1"; neededForBoot = true; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${hn}-boot"; neededForBoot = true; };
      "/" = { fsType = "zfs"; device = "${hn}pool/root"; neededForBoot = true; };
      "/nix" = { fsType = "zfs"; device = "${hn}pool/nix"; neededForBoot = true; };
      "/persist" = { fsType = "zfs"; device = "${hn}pool/persist"; neededForBoot = true; };
      "/home" = { fsType = "zfs"; device = "${hn}pool/home"; neededForBoot = true; };
    };
    swapDevices = [{ device = "/dev/disk/by-partlabel/${hn}-swap"; }];

    boot = {
      loader = {
        efi.efiSysMountPoint = "/efi";
        systemd-boot = {
          entriesMountPoint = "/boot";
        };
      };
      kernelModules = [ "iwlwifi" "ideapad_laptop" ];
      kernelParams = [
        "ideapad_laptop.allow_v4_dytc=1"
        # "zfs.zfs_arc_max=${builtins.toString (1023 * 1024 * (1024 * 6))}"
      ];
      initrd.availableKernelModules = [
        "xhci_pci"
        "xhci_hcd" # usb
        "nvme"
        "usb_storage"
        "sd_mod" # nvme / external usb storage
        "rtsx_pci_sdmmc" # sdcard
        "intel_agp"
        "usbnet"
      ];
      initrd.luks.devices."nixos-luksroot" = {
        device = "/dev/disk/by-partlabel/${hn}-luksroot";
        allowDiscards = true;
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };
    };
  };
}
