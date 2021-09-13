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

  config = {
    system.stateVersion = "21.05";

    nix.nixPath = [];
    nix.gc.automatic = true;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    # environment.systemPackages = with pkgs; [
    #   raspberrypifw
    #   raspberrypi-eeprom
    #   libraspberrypi
    #   picocom
    #   # # sudo rpi-eeprom-self-update
    #   # (pkgs.runCommandNoCC "rpi-eeprom-selfupdate" {} ''
    #   #   (
    #   #     set -x
    #   #     mkdir -p $out/

    #   #     # TODO Move some of this stuff to a "rpi-eeprom-sane" package
    #   #     # TODO "raspberrypi-eeprom{,-sane,-tools}"
    #   #     cp ${pkgs.raspberrypi-eeprom}/stable/vl805-latest.bin $out/vl805.bin
    #   #     sha256sum $out/vl805.bin | cut -d' ' -f1 > $out/vl805.sig

    #   #     cp ${pkgs.raspberrypi-eeprom}/stable/pieeprom-latest.bin $out/pieeprom.orig.bin
    #   #     ${pkgs.raspberrypi-eeprom}/bin/rpi-eeprom-config \
    #   #       --out $out/pieeprom.upd \
    #   #       --config ${eepromconfigtxt} \
    #   #       $out/pieeprom.orig.bin
    #   #     sha256sum $out/pieeprom.upd | cut -d' ' -f1 > $out/pieeprom.sig
    #   #   )
    #   # '')
    # ];

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
      #############3

      tmpOnTmpfs = false;
      cleanTmpDir = true;

      #kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;
      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_5_13;

      initrd.availableKernelModules = [
        "pcie_brcmstb" "bcm_phy_lib" "broadcom" "mdio_bcm_unimac" "genet"
        "vc4" "bcm2835_dma" "i2c_bcm2835"
        "xhci_pci" "nvme" "usb_storage" "sd_mod"
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
      networkmanager.enable = true;
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
      enableRedistributableFirmware = true;
    };
  };
}
