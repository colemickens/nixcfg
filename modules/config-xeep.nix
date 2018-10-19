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
    ./mixin-libvirt.nix
    ./mixin-thermald.nix
  ];

  config = {
    userOptions.cole = { tmuxColor="magenta"; bashColor="1;35"; };

    system.stateVersion = "18.09";
    time.timeZone = "America/Los_Angeles";

    ## TODO: move hardward config up and merge

    # hidpi stuff
    fonts.fonts = with pkgs; [ terminus_font ];
    i18n.consolePackages = [ pkgs.terminus_font ];
    i18n.consoleFont = "ter-v32n";

    # ignore psmouse, errors on Dell HW

    # newer kernel

    services.fwupd.enable = true;

    nix.nixPath = [ "/etc/nixos" "nixpkgs=/etc/nixpkgs" "nixos-config=/etc/nixos/configuration.nix" ];

    hardware = {
      bluetooth.enable = true;
      opengl.extraPackages = with pkgs; [ vaapiIntel ];
      pulseaudio.package = pkgs.pulseaudioFull;
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      #enableAllFirmware = true;
      u2f.enable = true;
    };

    powerManagement.enable = true;
    services.tlp.enable = true;

    networking = {
      hostName = "xeep";
      firewall.allowedTCPPorts = [ 3000 ];
      networkmanager.enable = true;
    };

    boot = {
      # earlyVconsoleSetup = true;
      blacklistedKernelModules = [ "psmouse" ];
      kernelPackages = pkgs.linuxPackages_testing;
      kernelPatches = [ trackpadPatch ];

      extraModulePackages = [ config.boot.kernelPackages.wireguard ];
      initrd.availableKernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
      kernelModules = [ "xhci_pci" "nvme" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" "intel_agp" "i915" ];
  
      # workaround Dell/NVME issue with s2idle
      # see: 
      #  - https://www.reddit.com/r/Dell/comments/8b6eci/xp_13_9370_battery_drain_while_suspended/
      #  - https://bugzilla.kernel.org/show_bug.cgi?id=199057
      #  - https://bugzilla.kernel.org/show_bug.cgi?id=196907
      # TODO: see if this is still needed with the XPS 13. A BIOS update has changed things somewhat
      # kernelParams = [ "mem_sleep_default=deep" ];

      kernelParams = [
        "i915.modeset=1"
        "i915.enable_guc=2"
        "i915.enable_gvt=1"
        "i915.enable_fbc=1"
        "i915.enable_psr=1"
        "i915.fastboot=1"
      ];
  
      initrd.luks.devices = [
        { 
          name = "root";
          device = "/dev/disk/by-partlabel/xeep-luks";
          preLVM = true;
          allowDiscards = true; # TODO
        }
      ];
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
    };
  
    fileSystems."/" = {
      device = "/dev/vg/root";
      fsType = "ext4";
    };
  
    fileSystems."/boot" = {
      device = "/dev/disk/by-partlabel/xeep-boot";
      fsType = "vfat";
    };
  
    swapDevices = [ ];
  
    nix.maxJobs = lib.mkDefault 8;
    powerManagement.cpuFreqGovernor = lib.mkDefault "powersave";
  };
}
