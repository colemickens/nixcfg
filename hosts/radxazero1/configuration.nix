{ pkgs, lib, modulesPath, extendModules, inputs, config, ... }:

let
  eth_ip = "192.168.162.69/16";
in
{
  imports = [
    ../rpi-sdcard.nix

    ../../profiles/core.nix
    ../../mixins/iwd-networks.nix

    ./unfree.nix

    inputs.tow-boot-radxa-zero.nixosModules.default
  ];
  config = {
    nixpkgs.hostPlatform.system = "aarch64-linux";

    nixcfg.common.useZfs = false;
    nixcfg.common.defaultNetworking = lib.mkForce true; # why rpi-sdcard??

    networking.hostName = "radxazero1";
    system.stateVersion = "21.11";

    services.tailscale.useRoutingFeatures = "server";
    networking.wireless.iwd.enable = true;

    # boot.initrd.systemd.network.networks."10-eth0".addresses =
    #   [{ addressConfig = { Address = eth_ip; }; }];
    system.build = rec {
      mbr_disk_id = "88888401";
    };

    boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
    # boot.kernelPackages = lib.mkForce pkgs.linuxPackages_5_18;
    boot.loader = {
      grub.enable = false;
      systemd-boot.enable = false;
      generic-extlinux-compatible = {
        enable = true;
      };
    };

    tow-boot.enable = true;
    tow-boot.autoUpdate = false;
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
