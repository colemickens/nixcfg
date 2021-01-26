{ pkgs, modulesPath, inputs, config, ... }:
let
  hostname = "rpione";
in
{
  imports = [
    ../../mixins/common.nix
    ../../profiles/user.nix

    ../../modules/other-arch-vm.nix
  ];

  # TODO: check in on cross-compiling
  # https://github.com/illegalprime/nixos-on-arm/blob/master/images/rpi0-otg-ether/default.nix

  config = {
    system.stateVersion = "21.03";

    nix.nixPath = [];
    nix.gc.automatic = true;

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

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

      loader.grub.enable = true;
      loader.grub.device = "/dev/disk/by-partlabel/FIRMWARE";
    };

    networking = {
      hostName = hostname;
      firewall.enable = true;
      firewall.allowedTCPPorts = [ 22 ];
      networkmanager.enable = false;
      wireless.iwd.enable = true;
      useNetworkd = true;
      useDHCP = false;
      interfaces."eth0".ipv4.addresses = [{
        address = "192.168.1.99";
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
