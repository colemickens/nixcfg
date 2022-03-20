{ config, pkgs, lib, inputs, ... }:
let
  hostname = "xeep";
in
{
  imports = [
    ../../profiles/interactive.nix
    ../../modules/loginctl-linger.nix

    ../../mixins/bolt.nix
    #../../mixins/docker.nix
    ../../mixins/logitech-mouse.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
    ../../mixins/samba.nix
    ../../mixins/syncthing.nix
    ../../mixins/zfs.nix

    ../../mixins/loremipsum-media/rclone-mnt.nix

    ./services/aria2.nix
    ./services/revproxy.nix
    ./services/home-assistant
    ./services/plex.nix
    ./services/unifi.nix

    # xps 13 9370 specific:
    ../../mixins/gfx-intel.nix
    inputs.hardware.nixosModules.dell-xps-13-9370
  ];

  config = {
    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "unifi-controller"
      "plexmediaserver"
    ];

    boot.kernel.sysctl."net.ipv4.ip_forward" = 1;
    boot.kernel.sysctl."net.ipv6.ip_forward" = 1;

    system.stateVersion = "21.05";

    nix.nixPath = [];
    nix.gc.automatic = true;
    nix.settings.max-jobs = 8;

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
        echo "hello"
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
      "/home" = {
        device = "tank2/home";
        fsType = "zfs";
      };
      "/nix" = {
        device = "tank2/nix2";
        fsType = "zfs";
      };
    };
    swapDevices = [];

    services.tlp.enable = lib.mkForce false;

    users.users.cole.linger = true;

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      initrd.availableKernelModules = [
        "xhci_pci" "xhci_hcd" # usb
        "nvme" "usb_storage" "sd_mod" # nvme / external usb storage
        "rtsx_pci_sdmmc" # sdcard
        "intel_agp" "i915" # intel integrated graphics
        "usbnet" "r8152" # usb ethernet adapter
        "msr"
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
      networkmanager.enable = true;
      wireless.enable = false;
      wireless.iwd.enable = false;
    };
    services.timesyncd.enable = true;
    time.timeZone = "America/Los_Angeles";

    hardware = {
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
    };
    services.fwupd.enable = true;
  };
}
