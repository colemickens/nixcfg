{ pkgs, lib, modulesPath, inputs, ... }:

let
  hostname = "rpitwo";
in {
  imports = [
    "${modulesPath}/installer/cd-dvd/sd-image-aarch64.nix"
    ../../mixins/common.nix
    ../../mixins/sshd.nix

    ../../profiles/user.nix
  ];
  config = {
    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
      libraspberrypi

      dnsutils
    ];

    nix.nixPath = [];
    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
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

    boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;

    boot.initrd.availableKernelModules = [ "xhci_pci" "usb_storage" ];
    boot.kernelModules = [ "xhci_pci" "usb_storage" ];

    boot.consoleLogLevel = lib.mkDefault 7;
  };
}
