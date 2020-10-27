{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  rpione_serial = "156b6214";
  rpitwo_serial = "e43b854b";
  rpitwo = inputs.self.nixosConfigurations.rpitwo;
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
    BOOT_ORDER=0xf412
    TFTP_PREFIX=0
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
    )
  '';

  tftp_parent_dir = pkgs.runCommandNoCC "build-uefi" {} ''
    mkdir -p $out

    #cp -a "''${pkgs.ipxe}/bin-aarch64-efi/ipxe.efi" $out/ipxe.efi

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
