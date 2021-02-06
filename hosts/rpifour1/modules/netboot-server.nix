{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  rpione_serial = "156b6214";
  rpitwo_serial = "e43b854b";
  rpitwo = ({ config, lib, pkgs, ... }: {
    imports = [
      "${pkgs.path}/nixos/modules/profiles/minimal.nix"
      ../profiles/interactive.nix
    ];
    config = {
      fileSystems."/" = {
        device = "10.40.0.1:/nfs/client1";
        fsType = "nfs";
        options = [ "x-systemd-device-timeout=4" "vers=4.1" "proto=tcp" "_netdev" ];
      };
      boot.tmpOnTmpfs = true;
      services.udisks2.enable = false;
      networking.wireless.enable = false;
      boot.kernelPackages = pkgs.linuxPackages_rpi4;
      boot.initrd.supportedFilesystems = lib.mkForce [ "vfat" "nfs" ];
      boot.supportedFilesystems = lib.mkForce [ "vfat" "nfs" ];
      nixpkgs.overlays = [ (self: super: {
        grub2 = super.callPackage ({runCommand, ...}: runCommand "grub-dummy" {} "mkdir $out") {};
      }) ];
      boot.blacklistedKernelModules = [
        "bcm2835_v4l2" "bcm2835_mmal_vchiq" "bcm2835_codec" "vc_sm_cma"
      ];
      environment.systemPackages = with pkgs; [
        raspberrypi-tools htop
      ];
      systemd.sockets."nix-daemon".enable = false;
      security.polkit.enable = false;
      boot.loader.grub.enable = false;
      services.openssh.enable = true;
      boot.consoleLogLevel = lib.mkDefault 7;
      boot.loader.generic-extlinux-compatible.enable = false;
    };
  });

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
  bootOrder="0xf241"; # network, sd, usbMSD, restart
  #bootOrder="0xf41"; # sd, usbMSD, restart

  eepromcfg = pkgs.writeText "eepromcfg.txt" ''
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
  '';

  configTxt = pkgs.writeText "config.txt" ''
    avoid_warnings=1
    kernel=zImage
  '';

  cmdline = pkgs.writeText "cmdline.txt" ''
    root=/dev/nfs nfsroot=10.40.0.1:/nfs/client1,vers=4.1,proto=tcp rw ip=dhcp rootwait elevator=deadline init=${nixos.config.system.build.toplevel}/init isolcpus=3
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
