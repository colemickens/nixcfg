{ pkgs, inputs, ... }:
let
  hostname = "xeep";
in
{
  imports = [
    ../../mixins/common.nix
    ../../mixins/gfx-intel.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ../../profiles/interactive.nix

    # xps 13 9370 specific:
    inputs.hardware.nixosModules.dell-xps-13-9370
  ];

  config = {
    environment.systemPackages = with pkgs; [
      (
        pkgs.writeScriptBin "dell-fix-power" ''
          #!/usr/bin/env bash
          oldval="$(sudo ${pkgs.msr-tools}/bin/rdmsr 0x1FC)"
          newval="$(( 0xFFFFFFFE & 0x$oldval ))"
          sudo ${pkgs.msr-tools}/bin/wrmsr -a 0x1FC "$val"
        ''
      )
    ];

    system.stateVersion = "20.09";

    services.timesyncd.enable = true;
    documentation.nixos.enable = false;

    fileSystems."/" = {
      device = "tank2/root";
      fsType = "zfs";
    };

    fileSystems."/nix" = {
      device = "tank2/nix";
      fsType = "zfs";
    };

    fileSystems."/persist" = {
      device = "tank2/persist";
      fsType = "zfs";
    };

    fileSystems."/semivolatile" = {
      device = "tank2/semivolatile";
      fsType = "zfs";
    };

    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/newboot";
      fsType = "vfat";
    };
    swapDevices = [];

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      tmpOnTmpfs = true;
      #zfs.requestEncryptionCredentials = true;
      kernelPackages = pkgs.linuxPackages_latest;
      initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelParams = [
        # HIGHLY IRRESPONSIBLE
        "noibrs"
        "noibpb"
        "nopti"
        "nospectre_v2"
        "nospectre_v1"
        "l1tf=off"
        "nospec_store_bypass_disable"
        "no_stf_barrier"
        "mds=off"
        "mitigations=off"

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
        };
      };
      loader = {
        timeout = 1;
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
    };
    networking = {
      hostId = "ef66d560";
      hostName = hostname;
      firewall = {
        enable = true;
        allowedTCPPorts = [ 5900 22 ];
        checkReversePath = "loose";
      };
      networkmanager.enable = true;
      networkmanager.wifi.backend = "iwd";
      wireguard.enable = true;
    };
    services.resolved.enable = true;

    nix.maxJobs = 8;
    nixpkgs.config.allowUnfree = true;

    hardware = {
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
    };
    services.fwupd.enable = true;
  };
}
