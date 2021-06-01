{ pkgs, lib, modulesPath, inputs, config, ... }:
let
  hostname = "rpizero1";
in
{
  imports = [
    ../../mixins/common.nix
    ../../profiles/user.nix

    ../../mixins/sshd.nix
    ../../mixins/tailscale.nix

    ./sd-image-raspberrypi.nix
  ];

  # TODO: check in on cross-compiling
  config = {
    system.stateVersion = "21.03";

    nix.nixPath = [];
    nix.gc.automatic = true;

    # force cross-compilation here
    #nixpkgs.system = "x86_64-linux"; # should be set in flake.nix anyway
    nixpkgs.crossSystem = lib.systems.examples.raspberryPi;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    security.polkit.enable = false;
    services.udisks2.enable = false;
    boot.enableContainers = false;
    programs.command-not-found.enable = false;
    environment.noXlibs = true;

    nix.package = lib.mkForce pkgs.nix;

    boot.initrd.availableKernelModules = lib.mkForce [ 
      "mmc_block"
      "usbhid"
      "hid_generic"
      "hid_microsoft"
     ];

    # rpizero stuffs
    # boot.otg = {
    #   enable = true;
    #   module = "ether";
    # };

    # fileSystems = {
    #   "/boot" = {
    #     device = "/dev/disk/by-partlabel/FIRMWARE";
    #     fsType = "vfat";
    #     options = [ "nofail" ];
    #   };
    #   "/" = {
    #     device = "/dev/disk/by-partlabel/NIXOS";
    #     fsType = "ext4";
    #   };
    # };

    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_rpi0;

      loader.grub.enable = false;
      loader.raspberryPi = {
        enable = true;
        uboot.enable = true;
        version = 0;
      };
    };

    networking = {
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
      wireless.enable = lib.mkForce false;
      wireless.iwd.enable = true;
      useNetworkd = true;
      useDHCP = false;
      search = [ "ts.r10e.tech" ];
    };
    services.resolved.enable = true;
    services.resolved.domains = [ "ts.r10e.tech" "test2.r10e.tech" ];
    systemd.network.enable = true;
    systemd.network.networks = {
      "01-eth0" = {
        name = "eth0";
        networkConfig = {
          DHCPServer = true;
          Address = "10.0.3.1";
        };
        dhcpServerConfig = {
          PoolOffset = 100;
          PoolSize = 2;
        };
      };
      "01-wlan0" = {
        name = "wlan0";
        networkConfig = {
          DHCP = "yes";
        };
      };
    };

    nixpkgs.config.allowUnfree = true;
    hardware = {
      firmware = with pkgs; [
        raspberrypiWirelessFirmware
      ];
    };
  };
}
