{ pkgs, modulesPath, inputs, config, ... }:
let
  hostname = "rpione";
in
{
  imports = [
    ../../mixins/common.nix
    ../../profiles/user.nix

    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ./rpi4-uboot-loader-mainline.nix
    #./rpi4-uboot-mainline.nix
    #./rpi4-uefi-mainline.nix
  ];

  config = {
    system.stateVersion = "21.03";

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
    ];

    # ZFS
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partlabel/boot";
        fsType = "vfat";
        options = [ "nofail" ];
      };
      "/" = {
        device = "tank/root";
        fsType = "zfs";
      };
      "/nix" = {
        device = "tank/nix";
        fsType = "zfs";
      };
      # TODO: add datasets for unifi and home-assistant and then add backup jobs
      # TODO: this requires migration before switching to this config
      #    --- plus actually figuring out the backups to make it worth the efforts
      # "/var/lib/hass" = {
      #   device = "tank/hass";
      #   fsType = "zfs";
      # };
      # "/var/lib/unifi" = {
      #   device = "tank/unifi";
      #   fsType = "zfs";
      # };
    };

    # TODO: mainline kernel shenanigans:
    # boot.kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;
    # ^ usb doesn't f**king work
    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_rpi4;
      initrd.availableKernelModules = [
        "pcie_brcmstb" "bcm_phy_lib" "broadcom" "mdio_bcm_unimac" "genet"
        "vc4" "bcm2835_dma" "i2c_bcm2835"
        "xhci_pci" "nvme" "usb_storage" "sd_mod" "sdhci_pci"
      ];
      kernelModules = config.boot.initrd.availableKernelModules;
    };

    networking = {
      hostId = "deadb00f";
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
      wireless.iwd.enable = true;
      useNetworkd = true;
      useDHCP = false;
      interfaces."eth0".ipv4.addresses = [{
        address = "192.168.1.2";
        prefixLength = 16;
      }];
      defaultGateway = "192.168.1.1";
      nameservers = [ "192.168.1.1" ];
      search = [ "ts.r10e.tech" ];
    };
    services.resolved.enable = true;
    services.resolved.domains = [ "ts.r10e.tech" ];
    systemd.network.enable = true;

    nixpkgs.config.allowUnfree = true;
    hardware = {
      enableRedistributableFirmware = true;
    };
  };
}
