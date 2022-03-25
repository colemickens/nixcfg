{ config, pkgs, lib, inputs, ... }:
let
  hostname = "raisin";
in
{
  imports = [
    ../../profiles/sway/default.nix

    ../../mixins/gfx-radeonsi.nix

    #../../mixins/android.nix
    ../../mixins/devshells.nix
    ../../mixins/ledger.nix
    ../../mixins/logitech-mouse.nix
    ../../mixins/plex-mpv.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix
    #../../mixins/tpm.nix
    ../../mixins/upower.nix
    ../../mixins/zfs.nix

    # ../../profiles/gaming.nix

    ../../modules/loginctl-linger.nix

    ../porty/grub-shim.nix

    #inputs.nixpkgs-kubernetes.nixosModules.kata-containers
    inputs.hardware.nixosModules.common-cmd-amd
    inputs.hardware.nixosModules.common-gpu-amd
    inputs.hardware.nixosModules.common-pc-laptop
    inputs.hardware.nixosModules.common-pc-laptop-ssd
    inputs.hardware.nixosModules.common-pc-ssd
  ];

  config = {
    users.users.cole.linger = true;

    nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      # look ma, no "unfree" (other than the redistributable firmware)
    ];

    # TODO: move somewhere more common!
    hardware.usbWwan.enable = true;

    environment.systemPackages = with pkgs; [
      efibootmgr
      p7zip
      cpio
      esphome
    ];
    system.stateVersion = "21.05";

    nix.nixPath = [ ];
    nix.gc.automatic = true;
    nix.settings.max-jobs = 8;

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
      "/backup" = {
        device = "raisintank/backup";
        fsType = "zfs";
      };
      "/home" = {
        device = "raisintank/home";
        fsType = "zfs";
      };
    };
    swapDevices = [ { device = "/dev/disk/by-partlabel/swap"; } ];

    services.logind.extraConfig = ''
      HandlePowerKey=hybrid-sleep
    '';

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

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
    };
    networking = {
      hostId = "ef66d342";
      hostName = hostname;
      firewall.enable = true;
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

    hardware = {
      bluetooth.enable = true;
      enableRedistributableFirmware = true;
      cpu.amd.updateMicrocode = true;
    };
    services.fwupd.enable = true;
  };
}
