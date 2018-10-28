{ config, lib, pkgs, ... }:

let
  trackpadPatch = {
    name = "apple-magic-trackpad2-driver-v3";
    patch = pkgs.fetchpatch {
      name = "trackpad.patch";
      url = "https://lkml.org/lkml/diff/2018/9/21/38/1";
      sha256 = "018wyjvw4wz79by38b1r6bkbl34p6686r66hg7g7vc0v24jkcafn";
    };
  };
  cfg = config.xeep;
in {
  imports = [
    ./common
    ./profile-gui.nix
    ./profile-sway.nix
    ./mixin-docker.nix
    ./mixin-sshd.nix
    ./mixin-thermald.nix
    ./mixin-yubikey.nix
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
      opengl.extraPackages = with pkgs; [ vaapiIntel ];
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
      kernelPackages = pkgs.linuxPackages_testing;
      kernelPatches = [ trackpadPatch ];
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
      firewall.allowedTCPPorts = [];
      networkmanager.enable = true;
    };
  };
}
