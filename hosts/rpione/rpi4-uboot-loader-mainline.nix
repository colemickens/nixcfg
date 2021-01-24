{ config, lib, pkgs, modulesPath, ... }:

{
  config = {
    boot = {
      loader.grub.enable = false;
      loader.raspberryPi.enable = true;
      loader.raspberryPi.version = 4;
      loader.raspberryPi.firmwareConfig = ''
        enable_uart=1
        arm_64bit=1
        kernel=u-boot-rpi.bin
        enable_gic=1
        armstub=armstub8-gic.bin
        disable_overscan=1
      '';
      loader.raspberryPi.uboot.enable = true;
      loader.raspberryPi.uboot.configurationLimit = 5;
    };
  };
}
