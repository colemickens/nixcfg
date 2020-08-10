{ config, pkgs, lib, modulesPath, ... }:

{
  imports = [
    #"${modulesPath}/profiles/base.nix"
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
  ];
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
  networking.firewall.allowedUDPPorts = [ 51820 ];

  boot = {
    loader.grub.enable = false;
    loader.raspberryPi.enable = true;
    loader.raspberryPi.version = 4;
    kernelPackages = pkgs.linuxPackages_rpi4;
    supportedFilesystems = [ "zfs" ];
    initrd.availableKernelModules = [ "xhci_pci" "usb_storage" ];
    kernelModules = [ "xhci_pci" "usb_storage" ];

    consoleLogLevel = lib.mkDefault 7;
  };
}