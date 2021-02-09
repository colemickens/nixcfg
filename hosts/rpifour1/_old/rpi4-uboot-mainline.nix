{ config, lib, pkgs, modulesPath, ... }:

let
  configTxt = pkgs.writeText "config.txt" ''
    enable_uart=1
    arm_64bit=1
    kernel=u-boot-rpi.bin
    enable_gic=1
    armstub=armstub8-gic.bin
    disable_overscan=1
    dtoverlay=disable-bt
    #device_tree_address=0x1f0000
  '';
  fwdir = "${pkgs.raspberrypifw}/share/raspberrypi/boot";
in {
  config = {
    boot = {
      loader.grub.enable = true;
      loader.grub.configurationLimit = 5;
      loader.grub.devices = [ "nodev" ];
      loader.grub.efiSupport = true;
      loader.grub.efiInstallAsRemovable = true;
      loader.grub.zfsSupport = true;
      loader.grub.extraFiles = {
        "config.txt" = configTxt;
        "u-boot-rpi.bin" = "${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin";
        "armstub8-gic.bin" = "${pkgs.raspberrypi-armstubs}/armstub8-gic.bin";
        "bcm2711-rpi-4-b.dtb" = "${fwdir}/bcm2711-rpi-4-b.dtb";
        #"bcm2711-rpi-4-b.dtb" = "${pkgs.linuxPackages_latest.kernel}/dtbs/broadcom/bcm2711-rpi-4-b.dtb";
        "bootcode.bin" = "${fwdir}/bootcode.bin";
        "fixup4.dat" = "${fwdir}/fixup4.dat";
        "start4.elf" = "${fwdir}/start4.elf";
      };
  };
}
