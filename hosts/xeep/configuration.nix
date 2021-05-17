{ config, pkgs, lib, inputs, ... }:
let
  hostname = "xeep";
in
{
  imports = [
    ../../mixins/logitech-mouse.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ../../profiles/interactive.nix
    #../../profiles/desktop-sway.nix
    ../../profiles/desktop-sway-unstable.nix
    #../../profiles/desktop-gnome.nix

    # xps 13 9370 specific:
    ../../mixins/gfx-intel.nix
    inputs.hardware.nixosModules.dell-xps-13-9370

    # put this thing to work:
    ../../mixins/runner.nix
  ];

  config = {
    system.stateVersion = "21.03";

    nix.nixPath = [];
    nix.gc.automatic = true;
    nix.maxJobs = 8;
    nix.package = pkgs.nix;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      (pkgs.writeScriptBin "dell-fix-power" ''
        #!/usr/bin/env bash
        oldval="$(sudo ${pkgs.msr-tools}/bin/rdmsr 0x1FC)"
        newval="$(( 0xFFFFFFFE & 0x$oldval ))"
        sudo ${pkgs.msr-tools}/bin/wrmsr -a 0x1FC "$newval"
      '')
    ];

    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partlabel/newboot";
        fsType = "vfat";
      };

      "/" = {
        device = "tank2/root";
        fsType = "zfs";
      };
      "/nix" = {
        device = "tank2/nix2";
        fsType = "zfs";
      };
    };
    swapDevices = [];

    services.tlp.enable = lib.mkForce false;

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelPackages = pkgs.linuxPackages_latest;
      initrd.availableKernelModules = [
        "xhci_pci" "xhci_hcd" # usb
        "nvme" "usb_storage" "sd_mod" # nvme / external usb storage
        "rtsx_pci_sdmmc" # sdcard
        "intel_agp" "i915" # intel integrated graphics
        "usbnet" "r8152" # usb ethernet adapter
      ];
      kernelModules = config.boot.initrd.availableKernelModules;
      kernelParams = [
        "mitigations=off" # YOLO
        "i915.modeset=1" # nixos-hw = missing
        "i915.enable_guc=3" # nixos-hw = missing
        "i915.enable_gvt=0" # nixos-hw = missing
        "i915.enable_fbc=1" # nixos-hw = 2
        "i915.enable_psr=1" # nixos-hw = missing?
        "i915.fastboot=1" # nixos-hw = missing?
      ];
      supportedFilesystems = [ "btrfs" "zfs" ];
      initrd.supportedFilesystems = [ "btrfs" "zfs" ];
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
      # initrd.network = {
      #   enable = true;
      #   ssh = {
      #     enable = true;
      #     port = 22;
      #     authorizedKeys = import ../../data/sshkeys.nix;
      #     hostKeys = [ "/etc/secrets/initrd/ssh_host_rsa_key" ];
      #   };
      # };
      loader.timeout = 1;
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      loader.systemd-boot.configurationLimit = 4;
    };
    networking = {
      hostId = "ef66d560";
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
      wireless.iwd.enable = true;
      useNetworkd = true;
      useDHCP = false;

      interfaces."wlan0".useDHCP = true;
      interfaces."enp56s0u1u3".useDHCP = true;
      interfaces."enp57s0u1u3".useDHCP = true;

      search = [ "ts.r10e.tech" ];
    };
    services.timesyncd.enable = true;
    services.resolved.enable = true;
    services.resolved.domains = [ "ts.r10e.tech" ];
    systemd.network.enable = true;

    nixpkgs.config.allowUnfree = true;
    hardware = {
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
    };
    services.fwupd.enable = true;
  };
}
