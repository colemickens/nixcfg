{ pkgs, modulesPath, inputs, config, ... }:
let
  hostname = "rpicore";
in
{
  imports = [
    ../../mixins/common.nix
    ../../profiles/user.nix

    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix
  ];

  /*
  if it's running as root... then it mounts to /run/secretdirs/
  this tool mounts Dictionaries to /run/user/1000/secretdirs/{dirname}/
  apps can then rely on it, user-access by default for some stuff
  can run as a daemon/tool in CI jobs easily
  can have dicts encrypted with different access keys
  - use sops as the "Backend"
  - the nix machine would then just mount hte backend 
  */

  config = {
    system.stateVersion = "21.05";

    nix.nixPath = [];
    nix.gc.automatic = true;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    environment.systemPackages = with pkgs; [
      raspberrypifw
      raspberrypi-eeprom
      libraspberrypi

      minicom
      screen
      ncdu
    ];

    nixpkgs.config.allowBroken = true;
    boot = {
      ############# TODO: replace with tow-boot when its not so damn slow with grub
      loader.grub.enable = false;
      loader.raspberryPi.enable = true;
      loader.raspberryPi.version = 4;
      loader.raspberryPi.firmwareConfig = ''
        dtoverlay=disable-wifi
        dtoverlay=disable-bt
        dtparam=sd_poll_once
      '';
      loader.raspberryPi.uboot.enable = true;
      loader.raspberryPi.uboot.configurationLimit = 5;
      #############

      tmpOnTmpfs = false;
      cleanTmpDir = true;

      #kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_5_15;
      kernelPatches = [{
        name = "kcore-config";
        patch = null;
        extraConfig = ''
          PROC_KCORE y
        '';
      }];

      initrd.availableKernelModules = [
        "pcie_brcmstb" "bcm_phy_lib" "broadcom" "mdio_bcm_unimac" "genet"
        "vc4" "bcm2835_dma" "i2c_bcm2835"
        "reset_raspberrypi" # needed for USB reset, so that USB works in kernel 5.14
        "xhci_pci" "nvme" "usbhid" "usb_storage" "sd_mod"
        "uas" # necessary for my UAS-enabled NVME-USB adapter
      ];
      kernelModules = config.boot.initrd.availableKernelModules;

      initrd.supportedFilesystems = [ "zfs" ];
      supportedFilesystems = [ "zfs" ];
    };

    networking = {
      hostId = "deadb00f";
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
      wireless.enable = false;
      wireless.iwd.enable = false;
      interfaces."eth0".ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 16;
      }];
      defaultGateway = "192.168.1.1";
      nameservers = [ "192.168.1.1" ];
    };
    services.timesyncd.enable = true;
    time.timeZone = "America/Los_Angeles";

    nixpkgs.config.allowUnfree = true;
    hardware = {
      # this pulls in firmware-nonfree which clashes with raspberrypiWirelessFirmware
      enableRedistributableFirmware = false;
    };
  };
}
