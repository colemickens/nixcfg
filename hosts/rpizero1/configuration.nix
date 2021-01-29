{ pkgs, modulesPath, inputs, config, ... }:
let
  hostname = "rpizero1";
in
{
  imports = [
    ../../mixins/common.nix
    ../../profiles/user.nix
  ];

  # TODO: check in on cross-compiling
  # https://github.com/illegalprime/nixos-on-arm/blob/master/images/rpi0-otg-ether/default.nix

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

    # rpizero stuffs
    boot.otg = {
      enable = true;
      module = "ether";
    };

    # ZFS
    fileSystems = {
      "/boot" = {
        device = "/dev/disk/by-partlabel/FIRMWARE";
        fsType = "vfat";
        options = [ "nofail" ];
      };
      "/" = {
        device = "/dev/disk/by-partlabel/NIXOS";
        fsType = "ext4";
      };
    };

    boot = {
      tmpOnTmpfs = false;
      cleanTmpDir = true;

      kernelPackages = pkgs.lib.mkForce pkgs.linuxPackages_latest;

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
      wireless.iwd.enable = true;
      useNetworkd = true;
      useDHCP = false;
      # TODO: how to do dhcpd from networkd?
      interfaces."eth0".ipv4.addresses = [{
        address = "10.0.3.1";
        prefixLength = 24;
      }];
      interfaces."wlan0".useDHCP = true;
      #defaultGateway = "192.168.1.1";
      nameservers = [ "1.1.1.1" ];
      #search = [ "ts.r10e.tech" ];
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
