{ pkgs, lib, modulesPath, inputs, ... }:

let
  hostname = "rpitwo";
in {
  imports = [
    #"${modulesPath}/installer/cd-dvd/sd-image-aarch64.nix"
    ./sd-aarch64.nix
    ../../mixins/common.nix
    ../../mixins/sshd.nix

    ../../profiles/user.nix
  ];
  config = {
    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
      raspberrypi-tools

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

    # grub, [questioning drake]
    # uboot, [enthusiast drake]
    boot.loader.grub.enable = false;
    boot.loader.raspberryPi.uboot.enable = true;

    # 5.10 has Rpi4 DRM support: https://www.phoronix.com/scan.php?page=news_item&px=RPi4-Display-Linux-5.10-Coming
    boot.kernelPackages = pkgs.linuxPackages_5_10;
    hardware.deviceTree = {
      enable = true;
      filter = "*rpi*dtb";
    };

    boot.initrd.availableKernelModules = [ "xhci_pci" "usb_storage" ];
    boot.kernelModules = [ "xhci_pci" "usb_storage" ];
 
    boot.consoleLogLevel = lib.mkDefault 7;
  };
}