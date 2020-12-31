{ pkgs, lib, config, modulesPath, inputs, ... }:

let
  hostname = "rpitwoefi";
in {
  imports = [
    #"${modulesPath}/installer/cd-dvd/sd-image-aarch64.nix"
    ../../mixins/common.nix
    ../../mixins/sshd.nix

    ../../profiles/user.nix
  ];
  config = rec {
    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
      libraspberrypi

      dnsutils
    ];

    # nixpkgs.overlays = [
    #   (old: pkgs: {
    #     mesa = pkgs.mesa-git; # mesa-20.3 for the new vulkan rpi4 changes
    #   })
    # ];

    # TODO, why can root ssh?

    nix.nixPath = [];
    documentation.enable = false;
    documentation.nixos.enable = false;
    networking.hostName = hostname;
    services.udisks2.enable = false;

    networking.wireless.enable = false;
    networking.interfaces."eth0".ipv4.addresses = [
      {
        address = "192.168.1.3";
        prefixLength = 16;
      }
    ];
    networking.defaultGateway = "192.168.1.1";
    networking.nameservers = [ "192.168.1.1" ];
    networking.useDHCP = false;
    networking.firewall.enable = true;

    fileSystems = {
      "/boot" = { device = "/dev/sda1"; };
      "/" = { device = "/dev/sda2"; };
    };

    boot.loader.grub.enable = false;
    boot.loader.systemd-boot.enable = false;
    boot.loader.systemd-boot.configurationLimit = 1;
    boot.loader.raspberryPi.enable = true;
    boot.loader.raspberryPi.version = 4;
    boot.loader.raspberryPi.uboot.enable = false;
    boot.loader.raspberryPi.rpi4uefi.enable = true;
    boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_5_10;

    boot.initrd.availableKernelModules = [ "xhci_pci" "usb_storage" ];
    boot.kernelModules = [ "xhci_pci" "usb_storage" ];

    system.build.newimg = import "${inputs.nixos-azure}/lib/make-disk-image.nix" {
      inherit pkgs lib config;
      diskSize = 1024;
      partitionTableType = "efi";
    };

    boot.consoleLogLevel = lib.mkDefault 7;
  };
}
