{ pkgs, lib, modulesPath, inputs, ... }:

let
  hostname = "rpitwo";
in {
  imports = [
    #"${modulesPath}/installer/cd-dvd/sd-image-aarch64.nix"
    "./sd-aarch64.nix"
    ../../mixins/common.nix
    ../../mixins/sshd.nix

    ../../profiles/user.nix
  ];
  config = {
    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
      raspberrypi-tools
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

    hardware.deviceTree = {
      enable = true;
      filter = "*rpi*dtb";
    };
    boot = {
      loader.grub.enable = false;
      loader.raspberryPi.uboot.enable = true;
      #kernelPackages = pkgs.linuxPackages_5_9; # whenever 5.10-rc1 is out... to test the new vc4/drm changes
      kernelPackages = pkgs.linuxPackages_5_10; # whenever 5.10-rc1 is out... to test the new vc4/drm changes
      #kernelPackages = pkgs.linuxPackages_rpi4;
      initrd.availableKernelModules = [ "xhci_pci" "usb_storage" ];
      kernelModules = [ "xhci_pci" "usb_storage" ];

      #supportedFilesystems = lib.mkForce [ "ext4" ];
      #initrd.supportedFilesystems = lib.mkForce [ "ext4" ];
      consoleLogLevel = lib.mkDefault 7;
    };
  };
}