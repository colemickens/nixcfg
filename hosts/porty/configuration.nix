{ config, pkgs, ... }:

{
  imports = [
    ../../mixins/common.nix

    ../../profiles/user.nix
    ../../profiles/gui.nix

    #../../profiles/specialisations.nix
    # or

    ../../modules/loginctl-linger.nix

    ../../mixins/nvidia.nix
    #../../profiles/desktop-sway-unstable-egl.nix
    ../../profiles/desktop-gnome.nix


    ../../mixins/libvirt.nix
    ../../mixins/logitech-mouse.nix
    ../../mixins/sshd.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix

    #./grub-isos.nix
  ];

  config = {
    users.users.cole.linger = true;

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
      { device = "/dev/mapper/porty-root";
        fsType = "ext4";
      };

    boot.initrd.luks.devices."porty-root".device = "/dev/disk/by-partlabel/porty-luks";

    fileSystems."/boot" =
      { device = "/dev/disk/by-partlabel/porty-boot";
        fsType = "vfat";
      };

    swapDevices = [ ];

    # This value determines the NixOS release from which the default
    # settings for stateful data, like file locations and database versions
    # on your system were taken. It‘s perfectly fine and recommended to leave
    # this value at the release version of the first install of this system.
    # Before changing this value read the documentation for this option
    # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
    system.stateVersion = "21.05"; # Did you read the comment?
  };
}
