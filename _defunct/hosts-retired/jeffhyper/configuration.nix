{ config, lib, pkgs, ... }:

{
  imports = [
    ../../profiles/interactive.nix

    ../../mixins/grub-signed-shim.nix
    ../../mixins/syncthing.nix
    ../../mixins/tailscale.nix

    ./user-jeff.nix
  ];

  config = {
    nixpkgs.hostPlatform.system = "x86_64-linux";

    system.stateVersion = "21.05";
    virtualisation.hypervGuest.enable = true;

    boot = {
      initrd.kernelModules = [ "hv_vmbus" "hv_storvsc" ]; # TODO: necessary ? or just in available in the module??
      kernel.sysctl."vm.overcommit_memory" = "1";
      initrd.availableKernelModules = [ "sd_mod" "sr_mod" ];
    };

    time.timeZone = "America/Chicago";

    networking.hostName = "jeffhyper";
    networking.hostId = lib.mkForce "deadbeef";
    systemd.network = {
      networks."20-eth0-static-ip" = {
        matchConfig.Name = "eth0";
        addresses = [{ addressConfig = { Address = "192.168.1.200/24"; }; }];
        networkConfig = {
          Gateway = "192.168.1.1";
          DNS = "192.168.1.1";
          IPForward = "yes";
        };
      };
      networks."20-eth1-static-ip" = {
        matchConfig.Name = "eth1";
        addresses = [{ addressConfig = { Address = "192.168.10.200/24"; }; }];
      };
    };

    fileSystems = {
      "/boot" = { fsType = "vfat"; device = "/dev/disk/by-label/BOOT"; };

      "/" = { fsType = "zfs"; device = "rpool/root"; };
      "/home" = { fsType = "zfs"; device = "rpool/home"; };
      "/nix" = { fsType = "zfs"; device = "rpool/nix"; };
      "/var" = { fsType = "zfs"; device = "rpool/var"; };
    };
    swapDevices = [ ];
  };
}
