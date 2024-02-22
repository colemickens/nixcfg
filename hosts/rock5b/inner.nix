{
  config,
  lib,
  pkgs,
  modulesPath,
  ...
}:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")

    ../../profiles/core.nix
    # ../../profiles/addon-sbc.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";
    system.stateVersion = "24.05";

    boot.initrd.availableKernelModules = [
      "nvme"
      "usb_storage"
    ];
    boot.initrd.kernelModules = [ ];

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;

    boot.kernelModules = [ ];
    boot.extraModulePackages = [ ];

    nixcfg.common.defaultKernel = false;
    nixcfg.common.useZfs = false;
    nixcfg.common.wifiWorkaround = true;

    fileSystems = {
      "/" = {
        device = "/dev/disk/by-partlabel/rock5b-nixos";
        fsType = "ext4";
      };
      "/efi" = {
        device = "/dev/disk/by-partlabel/rock5b-efi";
        fsType = "vfat";
      };
      "/boot" = {
        device = "/dev/disk/by-partlabel/rock5b-extboot";
        fsType = "vfat";
      };
    };

    swapDevices = [
      # TODO: add our swap device
    ];

    # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
    # (the default) this is the recommended approach. When using systemd-networkd it's
    # still possible to use this option, but it's recommended to use it in conjunction
    # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
    networking.useDHCP = lib.mkDefault true;
    # networking.interfaces.enP4p1s0.useDHCP = lib.mkDefault true;

    # Use the systemd-boot EFI boot loader.
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    boot.loader.efi.efiSysMountPoint = "/efi";
    boot.loader.systemd-boot.xbootldrMountPoint = "/boot";

    networking.hostName = "rock5b"; # Define your hostname.

    # Pick only one of the below networking options.
    # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
    # networking.networkmanager.enable = true;  # Easiest to use and most distros use this by default.

    # Set your time zone.
    # time.timeZone = "Europe/Amsterdam";

    # Configure network proxy if necessary
    # networking.proxy.default = "http://user:password@proxy:port/";
    # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

    # Select internationalisation properties.
    # i18n.defaultLocale = "en_US.UTF-8";
    # console = {
    #   font = "Lat2-Terminus16";
    #   keyMap = "us";
    #   useXkbConfig = true; # use xkb.options in tty.
    # };

    # Enable the X11 windowing system.
    # services.xserver.enable = true;
  };
}
