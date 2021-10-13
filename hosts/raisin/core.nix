{ config, pkgs, lib, inputs, ... }:
let
  hostname = "raisin";
in
{
  imports = [
    ../../mixins/common.nix

    ../../mixins/android.nix
    ../../mixins/ledger.nix
    ../../mixins/logitech-mouse.nix
    ../../mixins/plex-mpv.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    ../../mixins/tpm.nix
    ../../mixins/upower.nix

    ../../profiles/gaming.nix

    ../../modules/loginctl-linger.nix

    #inputs.nixpkgs-kubernetes.nixosModules.kata-containers
  ];

  config = {
    users.users.cole.linger = true;

    # TODO: move somewhere more common!
    hardware.usbWwan.enable = true;

    environment.systemPackages = with pkgs; [
      efibootmgr p7zip cpio
      yubikey-manager
      esphome
    ];
    system.stateVersion = "21.05";

    nix.nixPath = [];
    nix.gc.automatic = true;
    nix.maxJobs = 8;
    #nix.package = lib.mkForce pkgs.nix;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    # virtualisation.kata-containers.enable = true;

    # virtualisation.containerd.enable = true;
    # virtualisation.containerd.configFile =
    #   pkgs.writeText "containerd.conf" ''
    #     subreaper = true
    #     oom_score = -999

    #     [debug]
    #       level = "debug"
    #   '';
    # systemd.services.containerd.path = with pkgs; [ zfs ];

    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        fsType = "vfat";
      };

      "/" = {
        device = "raisintank/root";
        fsType = "zfs";
      };
      "/nix" = {
        device = "raisintank/nix";
        fsType = "zfs";
      };
      "/home" = {
        device = "raisintank/home";
        fsType = "zfs";
      };
    };
    swapDevices = [
      { device = "/dev/disk/by-partlabel/swap"; }
    ];

    services.logind.extraConfig = ''
      HandlePowerKey=hybrid-sleep
    '';

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelPackages = pkgs.linuxPackages_latest;
      zfs.enableUnstable = true;

      initrd.availableKernelModules = [
        "xhci_pci" "xhci_hcd" # usb
        "nvme" "usb_storage" "sd_mod" # nvme / external usb storage
        "rtsx_pci_sdmmc" # sdcard
        "intel_agp" "i915" # intel integrated graphics
        "usbnet" "r8152" # usb ethernet adapter
      ];
      kernelParams = [
        "mitigations=off" # YOLO
      ];
      supportedFilesystems = [ "btrfs" "zfs" ];
      initrd.supportedFilesystems = [ "btrfs" "zfs" ];
      initrd.luks.devices = {
        root = {
          name = "root";
          device = "/dev/disk/by-partlabel/luksroot";
          preLVM = true;
          allowDiscards = true;
          #fallbackToPassword = true;
        };
      };
      loader.timeout = 6;
      loader.systemd-boot.enable = true;
      loader.systemd-boot.configurationLimit = 5;
      loader.efi.canTouchEfiVariables = true;
    };
    networking = {
      hostId = "ef66d342";
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = true;
      wireless.enable = false;
      wireless.iwd.enable = false;
      useNetworkd = false;
      useDHCP = false;

      # interfaces."wlan0".useDHCP = true;
      # interfaces."w1p1s0".useDHCP = true;
      # interfaces."enp3s0f4u1u3".useDHCP = true;
      # interfaces."enp56s0u1u3".useDHCP = true;
      # interfaces."enp57s0u1u3".useDHCP = true;
      # interfaces."enp3s0f3u1u3".useDHCP = true;
      # interfaces."enp3s0f4u1u2u3".useDHCP = true;
      # interfaces."enp3s0f4u1u2".useDHCP = true;

      # search = [ "ts.r10e.tech" ];
    };
    services.timesyncd.enable = true;
    # services.resolved.enable = true;
    # services.resolved.domains = [ "ts.r10e.tech" "test22.r10e.tech" ];
    # systemd.network.enable = true;

    services.tlp.enable = true;

    nixpkgs.config.allowUnfree = true;
    hardware = {
      bluetooth.enable = true;
      enableRedistributableFirmware = true;
      cpu.amd.updateMicrocode = true;
    };
    services.fwupd.enable = true;
  };
}
