{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  hn = "rpifour1";
in
{
  imports = [
    ./core.nix
  ];

  config = {
    networking.hostName = hn;

    systemd.network = {
      networks."20-eth0-static-ip" = {
        matchConfig.Name = "eth0";
        addresses = [{ addressConfig = { Address = "192.168.1.2/16"; }; }];
        networkConfig = {
          Gateway = "192.168.1.1";
          DNS = "192.168.1.1";
          DHCP = "ipv6";
        };
      };
    };

    boot = {
      kernelParams = [
        # when (!no ATF and) the passthru dtb, this isnt needed hm
        "earlycon=uart8250,mmio32,0xfe215040"

        "earlyprintk"
        "console=ttyS1,115200"
        "console=tty1"
        "console=ttyS0,115200"
      ];
    };

    fileSystems = {
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-partlabel/${hn}-boot"; options = [ "nofail" ]; };
      "/boot/firmware" = { fsType = "vfat"; device = "/dev/disk/by-label/TOW-BOOT-FI"; options = [ "nofail" "ro" ]; };

      "/" = { fsType = "zfs"; device = "tank/root"; };
      "/nix" = { fsType = "zfs"; device = "tank/nix"; };
    };
  };
}
