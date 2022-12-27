{ config, pkgs, lib, inputs, ... }:

let
  hn = config.networking.hostName;
in
{
  imports = [
    ../../profiles/sway/default.nix
    ../../profiles/dev.nix
    ../../profiles/laptop.nix
    ../../profiles/gaming.nix

    ../../mixins/gfx-radeonsi.nix
    ../../mixins/gfx-debug.nix

    ../../mixins/android.nix
    ../../mixins/easyeffects.nix
    ../../mixins/hidpi.nix
    ../../mixins/ledger.nix
    ../../mixins/libvirt.nix
    ../../mixins/logitech-mouse.nix
    ../../mixins/hw-steelseries-aerox3.nix
    ../../mixins/obs.nix
    # ../../mixins/plex-mpv.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/upower.nix # TODO: check if used?
    ../../mixins/zfs.nix
    # ../../mixins/grub-signed-shim.nix # we use systemd + bootpart support

    # ./experimental.nix
    ./unfree.nix

    inputs.nixos-hardware.nixosModules.common-cpu-amd
    inputs.nixos-hardware.nixosModules.common-cpu-amd-pstate
    inputs.nixos-hardware.nixosModules.common-gpu-amd
    inputs.nixos-hardware.nixosModules.common-pc-laptop-ssd
  ];

  config = {
    system.stateVersion = "21.05";
    networking.hostName = "carbon";
    
    hardware.video.hidpi.enable = true;

    services.tailscale.useRoutingFeatures = "client";

    time.timeZone = lib.mkForce null; # we're on the move

    networking.firewall.checkReversePath = "loose";
    
    environment.systemPackages = with pkgs; [ yuzu-mainline ryujinx ];

    nixcfg.common.hostColor = "purple";
    nixcfg.common.skipMitigations = false;
    nixcfg.common.defaultWifi = true;

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
      loader.efi.efiSysMountPoint = "/efi";
      loader.grub.enable = false;
      loader.systemd-boot = {
        entriesMountPoint = "/boot";
        enable = true;
      };
      kernelModules = [ "iwlwifi" "ideapad_laptop" ];
      kernelParams = [
        "ideapad_laptop.allow_v4_dytc=1"
        "zfs.zfs_arc_max=${builtins.toString (1024 * 1024 * (1024 * 6))}"
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
        preLVM = true;
        allowDiscards = true;
        crypttabExtraOpts = [ "fido2-device=auto" ];
      };
    };
  };
}
