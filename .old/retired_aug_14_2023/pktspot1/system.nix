{
  imports = [
    ({
      boot.kernelModules = [ "dm_multipath" "dm_round_robin" "ipmi_watchdog" ];
      services.openssh.enable = true;
      system.stateVersion = "22.11";
    }
    )
    ({
      boot.initrd.availableKernelModules = [ "ahci" "xhci_pci" "nvme" "usbhid" ];
      boot.initrd.kernelModules = [ ];
      boot.kernelModules = [ "kvm-intel" ];
      boot.extraModulePackages = [ ];
      boot.kernelParams = [ "console=ttyS1,115200n8" ];

      hardware.enableRedistributableFirmware = true;
    }
    )
    ({ lib, ... }:
      {
        boot.loader = {
          systemd-boot.enable = true;
          efi.canTouchEfiVariables = true;
        };
        nix.settings.max-jobs = lib.mkDefault 64;
      }
    )
    ({
      swapDevices = [

        {
          device = "/dev/disk/by-id/nvme-KXG60ZNV256G_TOSHIBA_91FFC0VGFQA1-part2";
        }

      ];

      fileSystems = {

        "/boot/efi" = {
          device = "/dev/disk/by-id/nvme-KXG60ZNV256G_TOSHIBA_91FFC0VGFQA1-part1";
          fsType = "vfat";

        };


        "/" = {
          device = "/dev/disk/by-id/nvme-KXG60ZNV256G_TOSHIBA_91FFC0VGFQA1-part3";
          fsType = "ext4";

        };

      };

      boot.loader.efi.efiSysMountPoint = "/boot/efi";
    })
    ({ networking.hostId = "ef1927db"; }
    )
    ({ modulesPath, ... }: {
      networking.hostName = "pktspot1";
      networking.useNetworkd = true;


      systemd.network.networks."40-bond0" = {
        matchConfig.Name = "bond0";
        linkConfig = {
          RequiredForOnline = "carrier";
          MACAddress = "b4:96:91:b7:9e:14";
        };
        networkConfig.LinkLocalAddressing = "no";
        dns = [
          "147.75.207.207"
          "147.75.207.208"
        ];
      };


      boot.extraModprobeConfig = "options bonding max_bonds=0";
      systemd.network.netdevs = {
        "10-bond0" = {
          netdevConfig = {
            Kind = "bond";
            Name = "bond0";
          };
          bondConfig = {
            Mode = "802.3ad";
            LACPTransmitRate = "fast";
            TransmitHashPolicy = "layer3+4";
            DownDelaySec = 0.2;
            UpDelaySec = 0.2;
            MIIMonitorSec = 0.1;
          };
        };
      };


      systemd.network.networks."30-ens6f0" = {
        matchConfig = {
          Name = "ens6f0";
          PermanentMACAddress = "b4:96:91:b7:9e:14";
        };
        networkConfig.Bond = "bond0";
      };


      systemd.network.networks."30-ens6f2" = {
        matchConfig = {
          Name = "ens6f2";
          PermanentMACAddress = "b4:96:91:b7:9e:16";
        };
        networkConfig.Bond = "bond0";
      };



      systemd.network.networks."40-bond0".addresses = [
        {
          addressConfig.Address = "147.28.150.135/31";
        }
        {
          addressConfig.Address = "2604:1380:4502:4400::1/127";
        }
        {
          addressConfig.Address = "10.26.51.129/31";
        }
      ];
      systemd.network.networks."40-bond0".routes = [
        {
          routeConfig.Gateway = "147.28.150.134";
        }
        {
          routeConfig.Gateway = "2604:1380:4502:4400::";
        }
        {
          routeConfig.Gateway = "10.26.51.128";
        }
      ];
    }
    )
  ];
}
