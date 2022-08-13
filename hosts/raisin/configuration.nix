{ config, pkgs, lib, inputs, ... }:
let
  hostname = "raisin";
  hn = config.networking.hostName;
in
{
  imports = [
    # ../../profiles/sway/default.nix
    # ../../profiles/dev.nix
    ../../profiles/interactive.nix

    # TODO: necessary with the nixosHardware imports?
    ../../mixins/gfx-radeonsi.nix
    # ../../mixins/gfx-debug.nix

    # ../../mixins/android.nix
    # ../../mixins/devshells.nix
    ../../mixins/grub-signed-shim.nix
    # ../../mixins/hidpi.nix
    ../../mixins/libvirt.nix
    # ../../mixins/ledger.nix
    # ../../mixins/logitech-mouse.nix
    # ../../mixins/plex-mpv.nix
    # ../../mixins/snapclient-local.nix
    # ../../mixins/snapcast-sink.nix # doesn't work, feels like a privacy risk
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/upower.nix
    ../../mixins/wpa-full.nix
    ../../mixins/zfs.nix

    # ./services/rtsp-simple-server.nix

    # ./experimental.nix
      
    ./amdzen2.nix
    inputs.hardware.nixosModules.common-cpu-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-laptop-ssd
  ];

  config = {
    system.stateVersion = "21.05";
    networking.hostName = hostname;
      
    environment.systemPackages = with pkgs; [
      esphome
    ];

    hardware.bluetooth.enable = true;
    hardware.usbWwan.enable = true;

    services.tlp.enable = true;
    services.fwupd.enable = true;
    # services.kmscon.enable = true;   # kmscon breaks sway!
    # services.kmscon.hwRender = true; # though maybe not if hwRender is off?
    services.logind.extraConfig = ''
      HandlePowerKey=hybrid-sleep
    '';

    fileSystems = {
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${hn}-boot"; neededForBoot = true; };
      "/" = { fsType = "zfs"; device = "${hn}pool/root"; neededForBoot = true; };
      "/nix" = { fsType = "zfs"; device = "${hn}pool/nix"; neededForBoot = true; };
      "/backup" = { fsType = "zfs"; device = "${hn}pool/backup"; neededForBoot = true; };
      "/home" = { fsType = "zfs"; device = "${hn}pool/home"; neededForBoot = true; };
    };
    swapDevices = [{ device = "/dev/disk/by-partlabel/swap"; }];
    boot = {
      kernelModules = [ "iwlwifi" "ideapad_laptop" ];
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
      initrd.luks.devices."${hn}-luksroot" = {
        name = "${hn}-luksroot";
        device = "/dev/disk/by-partlabel/${hn}-luksroot";
        preLVM = true;
        allowDiscards = true;
        
        keyFile = "/lukskey";
        fallbackToPassword = true; # doesn't work if keyfile is present, but not a valid luks key
      };
      initrd.secrets = {
        "/lukskey" = pkgs.writeText "lukskey" "test";
      };
    };
  };
}
