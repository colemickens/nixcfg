{ pkgs, inputs, ... }:
let
  hostname = "xeep";
in
{
  imports = [
    ../../mixins/common.nix

    ../../mixins/chromecast.nix
    ../../mixins/docker.nix
    ../../mixins/libvirt.nix
    ../../mixins/sshd.nix
    ../../mixins/v4l2loopback.nix
    #../../mixins/loremipsum-media/rclone-cmd.nix

    ../../profiles/sway.nix

    # xps 13 9370 specific:
    ./power-management.nix
    inputs.hardware.nixosModules.dell-xps-13-9370
  ];

  config = {
    # services = {
    #   hydra = let
      
    #   in {
    #     enable = true;
    #     hydraURL = "https://localhost:3000";
    #     notificationSender = "hydra@cleo.cat";
    #     #buildMachinesFile = [];
    #     useSubstitutes = true;
    #     package = pkgs.hydra-unstable;
    #   };
    # };
    # services.cyclops = {
    #   enable = true;
    #   config = {
    #     "default" = {
    #       # I don't believe in global nix config
    #       # period.
    #       trustedSubstituters = [
    #         "nixpkgs-wayland.cachix.org"
    #         "nixos-wayland-apps.r10e.org"
    #         # r10e.org
    #         # r10e.services
    #         # r10e.technology
    #         # r10e.systems
    #         # reproducible.*
    #         # 
    #       ];
    #       remote-builders = [
    #         ""
    #         ""
    #       ];
    #     }
    #     "nixpkgs-wayland-x86_64-linux" = {
    #       flake = "github:colemickens/nixpkgs-wayland#packages.x86_64-linux";
    #     };
    #     "nixpkgs-wayland-x86_64-linux" = {
    #       flake = "github:colemickens/nixpkgs-wayland#packages.x86_64-linux";
    #     };
    #     "nixos-wayland-apps" = {
    #       flake = "github:colemickens/nixcfg#machines.xeep";
    #       extraArgs = {
    #         nextgen = true; # enable flakes + rename + new-cache
    #       };
    #       checkInterval = "60s"; # todo: common interval syntax?
    #       updateInputs = true;
    #     };
    #   }
    # };
    nix = {
      nixPath = [];
      #trustedUsers = ["hydra"];
    };
    # </lol stability>

    # <relocate>
    # TODO
    services.udev.packages = with pkgs; [ libsigrok ]; # doesn't work?
    services.ratbagd.enable = true;
    environment.systemPackages = with pkgs; [
      libratbag
      piper
      undervolt
      (
        pkgs.writeScriptBin "dell-fix-power" ''
          #!/usr/bin/env bash
          oldval="$(sudo ${pkgs.msr-tools}/bin/rdmsr 0x1FC)"
          newval="$(( 0xFFFFFFFE & 0x$oldval ))"
          sudo ${pkgs.msr-tools}/bin/wrmsr -a 0x1FC "$val"
        ''
      )
    ];
    # </relocate>

    system.stateVersion = "18.09"; # Did you read the comment?
    services.timesyncd.enable = true;
    documentation.nixos.enable = false;

    fileSystems = {
      "/" = { fsType = "zfs"; device = "rpool2/nixos"; };
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/nixos-boot"; };
      "/home" = { fsType = "zfs"; device = "rpool2/home"; };
    };
    swapDevices = [];

    console.earlySetup = true; # hidpi + luks-open  # TODO : STILL NEEDED?
    console.font = "ter-v32n";
    console.packages = [ pkgs.terminus_font ];

    boot = {
      zfs.requestEncryptionCredentials = true;
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
    programs.adb.enable = true;

    nix.maxJobs = 8;
    nixpkgs.config.allowUnfree = true;
    hardware = {
      bluetooth.enable = true;
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
    };
    services.fwupd.enable = true;
  };
}
