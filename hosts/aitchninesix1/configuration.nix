{ pkgs, lib, modulesPath, inputs, config, extendModules, ... }:

let
  hn = "aitchninesix1";
in
{
  config = {
    fileSystems = lib.mkDefault {
      "/boot" = {
        fsType = "vfat";
        device = "/dev/disk/by-partlabel/${hn}-boot";
      };
      "/" = {
        fsType = "ext4";
        device = "/dev/disk/by-partlabel/${hn}-nixos";
      };
    };

    tow-boot = {
      config = {
        defconfig = "rk3588_defconfig"; # only ali-override
        withExtDtb = "${kernel}/dtbs/rockchip/rk3588-nvr-demo-v10.dtb";
      };
    };
  };
}
