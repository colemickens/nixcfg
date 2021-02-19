{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  rpifour2_serial = "156b6214";
  rpifour2_mac = "dc-a6-32-59-d6-f8";
  rpifour2_config = ({ config, lib, pkgs, modulesPath, inputs, ... }: {
    imports = [
      "${modulesPath}/installer/netboot/netboot.nix"
      ../../../mixins/common.nix
      ../../../profiles/interactive.nix
    ];
    config = {
      # fileSystems."/" = lib.mkForce {
      #   device = "192.168.1.2:/rpifour2";
      #   fsType = "nfs";
      #   options = [ "x-systemd-device-timeout=20s" "vers=4.1" "proto=tcp" "_netdev" ];
      # };

      documentation.enable = false;
      documentation.doc.enable = false;
      documentation.info.enable = false;
      documentation.nixos.enable = false;

      boot.tmpOnTmpfs = true;
      services.udisks2.enable = false;
      networking.wireless.enable = false;
      boot.kernelPackages = pkgs.linuxPackages_5_10;
      boot.initrd.supportedFilesystems = lib.mkForce [ "vfat" "nfs" ];
      boot.initrd.kernelModules = [
        "nfs" "genet" "broadcom"
        "xhci_pci" "libphy" "bcm_phy_lib"
      ];
      boot.kernelModules = config.boot.initrd.kernelModules;
      networking.hostName = "rpifour2";
      networking.useDHCP = true;

      boot.initrd.network.enable = true;

      boot.supportedFilesystems = lib.mkForce [ "vfat" "nfs" ];
      nixpkgs.overlays = [ (self: super: {
        grub2 = super.callPackage ({runCommand, ...}: runCommand "grub-dummy" {} "mkdir $out") {};
      }) ];
      boot.blacklistedKernelModules = [
        "bcm2835_v4l2" "bcm2835_mmal_vchiq" "bcm2835_codec" "vc_sm_cma"
      ];
      environment.systemPackages = with pkgs; [
        libraspberrypi
        htop
      ];
      #systemd.sockets."nix-daemon".enable = false; #??
      security.polkit.enable = false;
      boot.loader.grub.enable = false;
      services.openssh.enable = true;
      boot.consoleLogLevel = lib.mkDefault 7;
      boot.loader.generic-extlinux-compatible.enable = false;
    };
  });
  rpifour2_system = import "${modulesPath}/../lib/eval-config.nix" {
    modules = [ rpifour2_config ];
    system = "aarch64-linux";
    specialArgs = { inherit inputs; };
  };

  # BOOT_ORDER fields::  0x0-NONE, 0x1-SD CARD, 0x2-NETWORK, 0x3-USB device boot, 0x4-USB MSD Boot, 0xf-RESTART(loop)
  bootOrder="0xf142";
  eepromcfg = pkgs.writeText "eepromcfg.txt" ''
    [all]
    BOOT_UART=0
    WAKE_ON_GPIO=1
    POWER_OFF_ON_HALT=0
    DHCP_TIMEOUT=20000
    DHCP_REQ_TIMEOUT=4000
    TFTP_FILE_TIMEOUT=30000
    ENABLE_SELF_UPDATE=1
    DISABLE_HDMI=0
    BOOT_ORDER=${bootOrder}
    TFTP_PREFIX=0
  '';

  configTxt = pkgs.writeText "config.txt" ''
    enable_uart=1
    uart_2ndstage=1
    dtoverlay=disable-bt
    dtoverlay=disable-wifi
    avoid_warnings=1
    arm_64bit=1
    kernel=vmlinuz
    initrd=initrd
    dtb=bcm2711-rpi-4-b.dtb
  '';

  earlycon = "earlycon=uart8250,mmio32,0xfe215040";
  #console = "console=ttyS0,115200";
  console = "";
  cmdline = pkgs.writeText "cmdline.txt" ''
    ${lib.optionalString (earlycon!="") earlycon} ${lib.optionalString (console!="") console} ip=dhcp root=/dev/nfs nfsroot=192.168.1.2:/rpifour2,vers=4.1,proto=tcp ro rootwait elevator=deadline init=${rpifour2_system.config.system.build.toplevel}/init isolcpus=3 nfsrootdebug
  '';

  cmdline2 = pkgs.writeText "cmdline.txt" ''
    init=${rpifour2_system.config.system.build.toplevel}/init initrd=initrd ${toString rpifour2_system.config.boot.kernelParams}
  '';

  tftp_parent_dir = pkgs.runCommandNoCC "build-tftp-dir" {} ''
    mkdir $out
    ln -s "${boot_dir}" "$out/${rpifour2_serial}"
  '';

  boot_dir  = pkgs.runCommandNoCC "build-tftp-dir" {} ''
    mkdir -p "$out"

    # PREPARE "vl805.{bin,sig}"
    cp ${pkgs.raspberrypi-eeprom}/stable/vl805-latest.bin $out/vl805.bin
    sha256sum $out/vl805.bin | cut -d' ' -f1 > $out/vl805.sig

    # PREPARE "pieeprom.{upd,sig}"
    ${pkgs.raspberrypi-eeprom}/bin/rpi-eeprom-config \
      --out "$out/pieeprom.upd" \
      --config ${eepromcfg} \
      ${pkgs.raspberrypi-eeprom}/stable/pieeprom-latest.bin
    sha256sum $out/pieeprom.upd | cut -d' ' -f1 > $out/pieeprom.sig

    ## FIRMWARE
    cp -r "${pkgs.raspberrypifw}/share/raspberrypi/boot/"/. $out/

    # ARM STUBS 8 (TODO, diff ones for 32 bit mode?)
    cp "${pkgs.raspberrypi-armstubs}/armstub8-gic.bin" $out/armstub8-gic.bin

    ## CONFIG.TXT
    cp "${configTxt}" $out/config.txt

    ## CMDLINE.TXT
    cp "${cmdline}" $out/cmdline.txt

    # LINUX KERNEL + INITRD
    cp ${rpifour2_system.config.system.build.toplevel}/kernel "$out/vmlinuz"
    cp ${rpifour2_system.config.system.build.toplevel}/initrd "$out/initrd"

    # PURGE EXISTING DTBS
    rm $out/*.dtb

    # LINUX MAINLINE DTBS
    for dtb in ${rpifour2_system.config.system.build.toplevel}/dtbs/{broadcom,}/bcm*.dtb; do
      dst="$target/$(basename $dtb)"
      cp $dtb "$out/"
    done
  '';
in
{
  config = {
    fileSystems = {
      "/var/lib/nfs/rpifour2" = {
        # sudo zfs create -o mountpoint=legacy tank/var/rpifour2
        device = "tank/var/rpifour2";
        fsType = "zfs";
      };
      "/var/lib/nfs/rpifour2/nix" = {
        device = "/nix/store";
        options = [ "bind" ];
      };
      "/export/rpifour2" = {
        device = "/var/lib/nfs/rpifour2";
        options = [ "bind" ];
      };
    };
    networking.firewall = {
      allowedUDPPorts = [
        67 69 4011
        111 2049 # nfs
        4000 4001 4002 # nfs
      ];
      allowedTCPPorts = [
        80 443
        9000
        111 2049 # nfs
        4000 4001 4002 # nfs
      ];
    };
    services.atftpd = {
      enable = true;
      extraOptions = [ "--verbose=7" ];
      root = "${tftp_parent_dir}";
    };
    services.nfs.server = {
      enable = true;
      statdPort = 4000;
      lockdPort = 4001;
      mountdPort = 4002;
      extraNfsdConfig = ''
        udp=y
      '';
      exports = ''
        /export             192.168.1.0/24(fsid=0,ro)
        /export/rpifour2    192.168.1.0/24(ro,nohide,no_root_squash,insecure,no_subtree_check)
      '';
    };
  };
}
