{ config, lib, pkgs, ... }:

let
  cfg = config.xeep;
in {
  imports = [
    ./common
    ./profile-gui.nix
    ./profile-sway.nix
    #./mixin-docker.nix
    ./mixin-libvirt.nix
    ./mixin-sshd.nix
    ./mixin-thermald.nix
    ./mixin-yubikey.nix
    ./pkgs-full.nix
  ];

  config = {
    userOptions.cole = { tmuxColor="magenta"; bashColor="1;35"; };

    system.stateVersion = "18.09";
    time.timeZone = "America/Los_Angeles";

    i18n.consolePackages = [ pkgs.terminus_font ]; # hidpi
    i18n.consoleFont = "ter-v32n"; # hidpi

    nix.maxJobs = lib.mkDefault 8;

    hardware = {
      bluetooth.enable = true;
      opengl = {
        enable = true;
        extraPackages = with pkgs; [ vaapiIntel vaapiVdpau libvdpau-va-gl ];
      };
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      u2f.enable = true;
    };

    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
    powerManagement.enable = true;
    services.tlp.enable = true;
    services.fwupd.enable = true;

    fileSystems = {
      "/" = {
        device = "/dev/vg/root";
        fsType = "ext4";
      };
      "/boot" = {
        device = "/dev/disk/by-partlabel/xeep-boot";
        fsType = "vfat";
      };
    };
    swapDevices = [ ];
    boot = {
      earlyVconsoleSetup = true; # hidpi + luks-open
      blacklistedKernelModules = [ "psmouse" ];
      kernelPackages = pkgs.linuxPackages_latest;
      extraModulePackages = [ config.boot.kernelPackages.wireguard ]; # (in case we want to use wireguard w/o the module)
      initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelParams = [
        "i915.modeset=1"
        "i915.enable_guc=2"
        "i915.enable_gvt=1"
        "i915.enable_fbc=1"
        "i915.enable_psr=1"
        "i915.fastboot=1"
        "mem_sleep_default=deep" # https://www.reddit.com/r/Dell/comments/8b6eci/xp_13_9370_battery_drain_while_suspended/
      ];
      initrd.luks.devices = [
        { 
          name = "root";
          device = "/dev/disk/by-partlabel/xeep-luks";
          preLVM = true;
          allowDiscards = true;
        }
      ];
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
    };
    networking = {
      hostName = "xeep";
      # temporary, do not commit
      firewall.enable = false;
      firewall.allowedTCPPorts = [];
      #wireless.iwd.enable = true;
      #useNetworkd = true;
      networkmanager.enable = true;
    };
    services.resolved.enable = true;
    #systemd.network = {
    #  enable = true;
      #networks."wired".DHCP = "ipv4";
      #networks."wired".matchConfig = { Name = "enp0s20f0u1u3"; };
      #networks."wireless".DHCP = "ipv4";
      #networks."wireless".matchConfig = { Name = "wlp2s0"; };
    #};
  };
}
