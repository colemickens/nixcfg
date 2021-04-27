{ config, pkgs, ... }:

{
  imports = [
    ./grub-isos.nix

    ../../mixins/common.nix

    ../../profiles/user.nix
    ../../profiles/interactive.nix
    ../../profiles/specialisations.nix

    ../../mixins/libvirt.nix
    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
  ];

  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.gpg.package = pkgs.gnupg23;
    };

    # Use the systemd-boot EFI boot loader.
    boot.loader.grub.enable = true;
    boot.loader.grub.devices = [ "nodev" ];
    boot.loader.grub.efiSupport = true;
    boot.loader.grub.efiInstallAsRemovable = true;
    boot.loader.efi.canTouchEfiVariables = false;
    boot.supportedFilesystems = [ "zfs" ];
    boot.kernelParams = [ "mitigations=off" ];

    nix.nixPath = [];

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [ hdparm ];

    networking.hostName = "porty"; # Define your hostname.
    networking.hostId = "abbadaba";
    
    networking.useDHCP = false;
    networking.interfaces.eth0.useDHCP = true;

    hardware = {
      enableRedistributableFirmware = true;
      cpu.intel.updateMicrocode = true;
      cpu.amd.updateMicrocode = true;
    };
    boot.initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
    boot.initrd.kernelModules = [
      "hv_vmbus"
      #"hv_storsvc"
      "hyperv_keyboard"
      "hid_hyperv"

      "xhci_pci"
      "nvme"
      "usb_storage"
      "sd_mod"
      "ehci_pci"
      "uas"
    ];
    boot.kernelModules = [ ];
    boot.kernelPackages = pkgs.linuxPackages_latest;
    boot.extraModulePackages = [ ];

    fileSystems."/" =
      { device = "/dev/disk/by-uuid/922d29e8-08af-4a8f-88d7-ad8aff978d4c";
        fsType = "ext4";
      };

    boot.initrd.luks.devices."root".device = "/dev/disk/by-uuid/a1f97902-a36f-4523-a119-fbefb2ad9638";

    fileSystems."/boot" =
      { device = "/dev/disk/by-uuid/879F-1940";
        fsType = "vfat";
      };

    swapDevices = [ ];

    virtualisation.hypervGuest.enable = true;
    
    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "20.09"; # Did you read the comment?
  };
}
