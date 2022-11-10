{ pkgs, lib, modulesPath, inputs, config, ... }:

let
  eth_ip = "192.168.162.69/16";
  kernel = pkgs.callPackage ./kernel.nix {};
  kernelPackages = pkgs.linuxKernel.packagesFor kernel;
in
{
  imports = [
    ./unfree.nix
    
    ../../mixins/common.nix
    ../../mixins/iwd-networks.nix
  ]
  ++ inputs.tow-boot-radxa-rock5b.nixosModules
  ;
  config = {
    nixcfg.common = {
      useZfs = false;
      defaultKernel = false;
    };
    
    networking.hostName = "rockfiveb1";
    system.stateVersion = "21.11";
    # boot.initrd.systemd.network.networks."10-eth0".addresses =
    #   [{ addressConfig = { Address = eth_ip; }; }];
    system.build = rec {
      mbr_disk_id = "888885b1";
    };

    fileSystems = {
      "/" = {
        fsType = "ext4";
        # device = "/dev/disk/by-partlabel/${hn}-root-ext4";
        device = "/dev/disk/by-partuuid/${config.system.build.mbr_disk_id}-3";
      };
    };
    
    boot.kernelPackages = kernelPackages;
    # boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_18;
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible = {
      enable = true;
    };

    tow-boot.enable = true;
    tow-boot.autoUpdate = false;
    tow-boot.device = "radxa-rock5b";
    # configuration.config.Tow-Boot = {
    tow-boot.config = ({
      diskImage.mbr.diskID = config.system.build.mbr_disk_id;
      # useDefaultPatches = false;
      # withLogo = false;
    });
  };
}
