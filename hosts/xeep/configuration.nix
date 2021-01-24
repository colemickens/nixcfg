{ pkgs, inputs, ... }:
let
  hostname = "xeep";
in
{
  imports = [
    ../../mixins/common.nix
    ../../mixins/gfx-intel.nix
    ../../mixins/libvirt.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ../../profiles/interactive.nix
    ../../profiles/desktop-sway.nix

    ../../profiles/gaming.nix

    # xps 13 9370 specific:
    inputs.hardware.nixosModules.dell-xps-13-9370
  ];

  config = {
    system.stateVersion = "21.03";

    nix.nixPath = [];
    nix.gc.automatic = true;
    nix.maxJobs = 8;

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
      "/" = {
        device = "tank2/root";
        fsType = "zfs";
      };
      "/nix" = {
        device = "tank2/nix2";
        fsType = "zfs";
      };
      "/boot" = {
        device = "/dev/disk/by-partlabel/newboot";
        fsType = "vfat";
      };
    };
    swapDevices = [];

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelPackages = pkgs.linuxPackages_latest;
      initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
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
          fallbackToPassword = true;
        };
      };
      loader.timeout = 1;
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
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

      interfaces."eth0".useDHCP = true;
      interfaces."enp56s0u2u3".useDHCP = true;
      interfaces."wlan0".useDHCP = true;

      bridges."virbr0".interfaces = [ "enp56s0u2u3" ];
      interfaces."virbr0".useDHCP = true;

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
