{ config, pkgs, lib, inputs, ... }:
let
  hostname = "raisin";
in
{
  imports = [
    ../../mixins/android.nix
    ../../mixins/common.nix

    ../../mixins/logitech-mouse.nix
    ../../mixins/obs.nix
    ../../mixins/sshd.nix
    #../../mixins/tailscale.nix
    ../../mixins/tpm.nix

    ../../profiles/desktop-sway-unstable.nix
    #../../profiles/desktop-gnome.nix

    inputs.nixpkgs-kubernetes.nixosModules.kata-containers
  ];

  config = {
    environment.systemPackages = with pkgs; [
      efibootmgr p7zip cpio
      yubikey-manager
    ];
    system.stateVersion = "21.03";

    nix.nixPath = [];
    nix.gc.automatic = true;
    nix.maxJobs = 8;
    nix.package = lib.mkForce pkgs.nix;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    virtualisation.kata-containers.enable = true;
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
    swapDevices = [];

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
      loader.timeout = 1;
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
    };
    networking = {
      hostId = "ef66d342";
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
      wireless.iwd.enable = true;
      useNetworkd = true;
      useDHCP = false;

      interfaces."wlan0".useDHCP = true;
      interfaces."w1p1s0".useDHCP = true;
      interfaces."enp3s0f4u1u3".useDHCP = true;
      interfaces."enp56s0u1u3".useDHCP = true;
      interfaces."enp57s0u1u3".useDHCP = true;
      interfaces."enp3s0f3u1u3".useDHCP = true;

      search = [ "ts.r10e.tech" ];
    };
    services.timesyncd.enable = true;
    services.resolved.enable = true;
    services.resolved.domains = [ "ts.r10e.tech" "test22.r10e.tech" ];
    systemd.network.enable = true;

    services.tlp.enable = true;

    nixpkgs.config.allowUnfree = true;
    hardware = {
      enableRedistributableFirmware = true;
      cpu.amd.updateMicrocode = true;
    };
    services.fwupd.enable = true;
  };
}
