{ pkgs, lib, modulesPath, inputs, ... }:

let
  hostname = "rpitwo";
in {
  imports = [
    #"${modulesPath}/profiles/base.nix"
    ../../mixins/common.nix
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
  ];
  config = {
    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
      raspberrypi-tools
    ];

    services.mingetty.autologinUser = lib.mkForce "root";
    systemd.services.sshd.wantedBy = lib.mkOverride 0 [ "multi-user.target" ];

    fileSystems."/var/lib" = {
      device = "192.168.1.2:/${hostname}";
      fsType = "nfs";
    };

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

    boot = {
      kernelPackages = pkgs.linuxPackages_latest;
      #supportedFilesystems = [ "ext4" "zfs" ];
      initrd.availableKernelModules = [ "xhci_pci" "usb_storage" ];
      kernelModules = [ "xhci_pci" "usb_storage" ];
    };
  };
}