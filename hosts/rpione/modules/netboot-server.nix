{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  rpione_serial = "156b6214";
  rpitwo_serial = "e43b854b";
  rpitwo = inputs.self.nixosConfigurations.rpitwonet;

  /*
  BOOT_ORDER fields
  The BOOT_ORDER property defines the sequence for the different boot modes. It is read right to left and up to 8 digits may be defined.

      0x0 - NONE (stop with error pattern)
      0x1 - SD CARD
      0x2 - NETWORK
      0x3 - USB device boot - Reserved - Compute Module only.
      0x4 - USB mass storage boot (since 2020-09-03)
      0xf - RESTART (loop) - start again with the first boot order field. (since 2020-09-03)

  Default: 0xf41 (0x1 in versions prior to 2020-09-03)
  Version: 2020-04-16

      Boot mode 0x0 will retry the SD boot if the SD card detect pin indicates that the card has been inserted or replaced.
      The default boot order is 0xf41 which means continuously try SD then USB mass storage.
  */
  #bootOrder="0xf412"; # network, sd, usbMSD, restart
  bootOrder="0xf41"; # sd, usbMSD, restart

  configtxt = pkgs.writeText "config.txt" ''
    [all]
    BOOT_UART=0
    WAKE_ON_GPIO=1
    POWER_OFF_ON_HALT=0
    DHCP_TIMEOUT=45000
    DHCP_REQ_TIMEOUT=4000
    TFTP_FILE_TIMEOUT=30000
    ENABLE_SELF_UPDATE=1
    DISABLE_HDMI=0
    BOOT_ORDER=${bootOrder}
    TFTP_PREFIX=0

    [pi4]
    arm_64bit=1
    kernel=u-boot-rpi4.bin
    enable_gic=1
    armstub=armstub8-gic.bin
  '';

  uefi_dir_with_update = pkgs.runCommandNoCC "build-tftp-rpitwo" {} ''
    (
      set -x
      mkdir -p $out/

      cp -r "${pkgs.rpi4-uefi}/boot"/. $out/

      # TODO Move some of this stuff to a "rpi-eeprom-sane" package
      # TODO "raspberrypi-eeprom{,-sane,-tools}"
      cp ${pkgs.raspberrypi-eeprom}/stable/vl805-latest.bin $out/vl805.bin
      sha256sum $out/vl805.bin | cut -d' ' -f1 > $out/vl805.sig

      cp ${pkgs.raspberrypi-eeprom}/stable/pieeprom-latest.bin $out/pieeprom.orig.bin
      ${pkgs.raspberrypi-eeprom}/bin/rpi-eeprom-config \
        --out $out/pieeprom.upd \
        --config ${configtxt} \
        $out/pieeprom.orig.bin
      sha256sum $out/pieeprom.upd | cut -d' ' -f1 > $out/pieeprom.sig

      # TODO: do the same with the vl805.bin firmware?
      # TODO: auto-script to make sure our own firmware is updated?
      # TODO: this can take out an entire cluster if a bad update were pushed

      mkdir $out/grub/
      ${pkgs.grub2}/bin/grub-mknetdir --net-directory=$out/grub/
    )
  '';

  tftp_parent_dir = pkgs.runCommandNoCC "build-uefi" {} ''
    mkdir -p $out

    #cp -a "''${pkgs.ipxe}/bin-aarch64-efi/ipxe.efi" $out/ipxe.efi

    # copy u-boot stuff to boot dir
    # name it and write config.txt

    # copy grub.efi to boot dir
    # load entries from http server

    ln -s ${uefi_dir_with_update}/ $out/${rpione_serial}
    ln -s ${uefi_dir_with_update}/ $out/${rpitwo_serial}
  '';

  boot_dir = pkgs.runCommandNoCC "build-bootdir" {} ''
    (
      set -x
      mkdir -p $out
      cat ${rpitwo.config.system.build.toplevel}/kernel > $out/linux.efi
      #cat {rpitwo.config.system.build.netbootRamdisk}/initrd >> $out/linux.efi
    )
  '';

  nixos = import "${modulesPath}/../lib/eval-config.nix" {
    modules = [ (import ../rpitwonet/configuration.nix) ];
    system = "aarch64-linux";
  };
  build = nixos.config.system.build;
in
{
  config = {
    services = {
      nginx = {
        enable = true;
        virtualHosts."grubboot" = {
          listen = [ { addr = "0.0.0.0"; port = 9000; } ];
          root = "${boot_dir}";
        };
      };
      atftpd = {
        enable = true;
        extraOptions = [ "--verbose=7" ];
        root = "${tftp_parent_dir}";
      };
    };
    networking.firewall.allowedUDPPorts = [ 67 69 4011 ];
    networking.firewall.allowedTCPPorts = [ 80 443 9000 ];
  };
}
