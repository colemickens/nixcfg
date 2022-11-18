{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

let
  eth_ip = "192.168.162.69/16";
in
{
  imports = [
    ../rpi-sdcard.nix
    ./unfree.nix

    ../../profiles/viz
    ../../mixins/wpa-full.nix
  ]
  ++ inputs.tow-boot-radxa-rock5b.nixosModules
  ;
  config = {
    nixcfg.common.useZfs = false;
    
    networking.hostName = "radxazero1";
    system.stateVersion = "21.11";
    # boot.initrd.systemd.network.networks."10-eth0".addresses =
    #   [{ addressConfig = { Address = eth_ip; }; }];
    system.build = rec {
      mbr_disk_id = "88888401";
    };
    
    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    # boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_18;
    boot.loader.grub.enable = false;
    boot.loader.generic-extlinux-compatible = {
      enable = true;
    };

    tow-boot.enable = true;
    tow-boot.autoUpdate = true;
    tow-boot.device = "radxa-zero";
    # configuration.config.Tow-Boot = {
    tow-boot.config = ({
      allowUnfree = true; # new, radxa specific
      diskImage.mbr.diskID = config.system.build.mbr_disk_id;
      uBootVersion = "2022.04";
      useDefaultPatches = false;
      withLogo = false;
    });
  };
}
