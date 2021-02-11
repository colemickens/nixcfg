{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  nfsServer = "192.168.1.2";
  nfsPath = "/nfs/rpifour2";
  rpifour2_serial = "e43b854b";
  rpifour2_config = ({ config, lib, pkgs, modulesPath, inputs, ... }: {
    imports = [
      "${modulesPath}/installer/netboot/netboot.nix"
      ../../../profiles/interactive.nix
    ];
    config = {
      fileSystems."/" = lib.mkForce {
        device = "${nfsServer}:${nfsPath}";
        fsType = "nfs";
        options = [ "x-systemd-device-timeout=4" "vers=4.1" "proto=tcp" "_netdev" ];
      };
      boot.tmpOnTmpfs = true;
      services.udisks2.enable = false;
      networking.wireless.enable = false;
      boot.kernelPackages = pkgs.linuxPackages_latest;
      boot.initrd.supportedFilesystems = lib.mkForce [ "vfat" "nfs" ];
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
  bootOrder="0xf241"; # network, sd, usbMSD, restart
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
    arm_64bit=1
  '';

  cmdline = pkgs.writeText "cmdline.txt" ''
    root=/dev/nfs nfsroot=${nfsServer}:${nfsPath},vers=4.1,proto=tcp rw ip=dhcp rootwait elevator=deadline init=${rpifour2_system.config.system.build.toplevel}/init isolcpus=3
  '';

  tftp_parent_dir = pkgs.runCommandNoCC "build-uefi" {} ''
    mkdir -p $out/${rpifour2_serial}

    cp ${rpifour2_system.config.system.build.toplevel}/kernel > $out/vmlinuz
    cp ${rpifour2_system.config.system.build.toplevel}/kernel > $out/initrd
  '';
in
{
  config = {
    services = {
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
