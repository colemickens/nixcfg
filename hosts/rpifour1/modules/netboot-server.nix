{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  rpifour2_serial = "156b6214";
  rpifour2_mac = "dc-a6-32-59-d6-f8";

  #netbootSystem = "aarch64-linux";
  netbootSystem = "armv7l-linux";
  isArm64Bit = (netbootSystem == "aarch64-linux");

  rpifour2_evalconfig = if (netbootSystem == "aarch64-linux")
    then "${modulesPath}/../lib/eval-config.nix"                # use whatever rpifour1 uses when we just follow it
    else "${inputs.nixos-unstable}/nixos/lib/eval-config.nix";  # use nixos-unstable so we get cache hits on floweringash's armv7 cache
  # we only need this ^ for bootstrapping, so this might be removed later

  rpifour2_config = ({ config, lib, pkgs, modulesPath, inputs, ... }: {
    imports = [
      "${modulesPath}/installer/netboot/netboot.nix"
    ../../../mixins/common.nix
    ../../../profiles/user.nix
    ];
    config = {
      fileSystems = {
        "/" = lib.mkForce {
          device = "192.168.1.2:/export/rpifour2";
          fsType = "nfs";
          options = [
            "x-systemd-device-timeout=20s"
            "nfsvers=3" "proto=tcp" "nolock" "rw" # so that it works in initrd with busybox's mount that only does nfs3
          ];
          neededForBoot = true;
        };
        "/nix/.ro-store" = lib.mkForce {
          device = "192.168.1.2:/export/nix-store";
          fsType = "nfs";
          options = [
            "x-systemd-device-timeout=20s"
            "nfsvers=3" "proto=tcp" "nolock" "ro" # so that it works in initrd with busybox's mount that only does nfs3
          ];
          neededForBoot = true;
        };
        "/dbimport" = lib.mkForce {
          device = "192.168.1.2:/export/nix-db-export";
          fsType = "nfs";
          options = [
            "x-systemd-device-timeout=20s"
            "nfsvers=3" "proto=tcp" "nolock" "ro" # so that it works in initrd with busybox's mount that only does nfs3
          ];
          neededForBoot = true;
        };
      };

      documentation.enable = false;
      documentation.doc.enable = false;
      documentation.info.enable = false;
      documentation.nixos.enable = false;

      systemd.timers."nix-db-import" = {
        wantedBy = [ "timers.target" ];
        partOf = [ "nix-db-import.service" ];
        timerConfig.OnCalendar = "5 minute";
      };
      systemd.services."nix-db-import" = {
        wantedBy = [ "multi-user.target" ]; 
        #after = [ "network.target" ];
        description = "Make regular imports of the nix database.";
        # TODO: let systemd let this see /nix ?
        serviceConfig = {
          Type = "simple";
          ExecStart = (pkgs.writeScript "load-db.sh" ''
            #!${pkgs.bash}/bin/bash
            set -x
            set -euo pipefail
            time ${pkgs.nix}/bin/nix-store --load-db </dbimport/snapshot
          '');
        };
      };

      # TODO???
      hardware.bluetooth.powerOnBoot = false; # attempt to disable BT?

      boot = {
        tmpOnTmpfs = true;
        kernelPackages = pkgs.linuxPackages_latest;
        kernelParams = [
          # unsure what this does?
          #"earlycon=uart8250,mmio32,0xfe215040"
          # doesn't work (maybe because of the overlay not lining up):
          #"console=ttyAMA0,115200"
          #"console=ttyS0,115200"
          #"console=serial0,115200"
        ];
        kernelPatches = if pkgs.system == "armv7l-linux" then [] else [{
          name = "crashdump-config";
          patch = null;
          # we mostly do this as a (hopeful) workaround:
          # otherwise initrd-network tries to startup too early
          # sometimes and interrupts genet's initialization process

          # TODO:
          # BROADCOM_PHYLIB
          # ??

          extraConfig = ''
            BCMGENET y
          '';
        }];
        initrd.supportedFilesystems = lib.mkForce [ "vfat" "nfs" ];
        initrd.kernelModules = [
          "nfs" "genet" "broadcom"
          "xhci_pci" "libphy" "bcm_phy_lib" "mdio_bcm_unimac"
        ];
        kernelModules = config.boot.initrd.kernelModules;
        initrd.network.enable = true;
        initrd.network.flushBeforeStage2 = false;
        supportedFilesystems = lib.mkForce [ "vfat" "nfs" ];
      };
      services.udisks2.enable = false;
      networking = {
        wireless.enable = false;
        hostName = "rpifour2";
        #useNetworkd = true;
        useDHCP = true;
        # interfaces."eth0".ipv4.addresses = [{
        #   address = "192.168.1.3";
        #   prefixLength = 16;
        # }];
      };
      nixpkgs.overlays = [ (self: super: {
        grub2 = super.callPackage ({runCommand, ...}: runCommand "grub-dummy" {} "mkdir $out") {};
      }) ];
      environment.systemPackages = with pkgs; [ libraspberrypi htop ];
      security.polkit.enable = false;
      boot.loader.grub.enable = false;
      services.openssh.enable = true;
      boot.consoleLogLevel = lib.mkDefault 7;
      boot.loader.generic-extlinux-compatible.enable = false;
    };
  });
  rpifour2_system = import "${modulesPath}/../lib/eval-config.nix" {
    modules = [ rpifour2_config ];
    system = netbootSystem;
    specialArgs = { inherit inputs; };
  };
  rpifour2_cmdline = pkgs.writeText "cmdline.txt" ''
    systemConfig=${rpifour2_system.config.system.build.toplevel} init=${rpifour2_system.config.system.build.toplevel}/init ${toString rpifour2_system.config.boot.kernelParams}
  '';

  # BOOT_ORDER fields::  0x0-NONE, 0x1-SD CARD, 0x2-NETWORK, 0x3-USB device boot, 0x4-USB MSD Boot, 0xf-RESTART(loop)
  bootOrder="0xf142";
  eepromcfg = pkgs.writeText "eepromcfg.txt" ''
    [all]
    BOOT_UART=1
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
    dtparam=sd_poll_once
    avoid_warnings=1
    kernel=vmlinuz
    initramfs initrd followkernel
    dtb=bcm2711-rpi-4-b.dtb
    core_freq=500
    ${lib.optionalString isArm64Bit "arm_64bit=1"}
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
    cp "${rpifour2_cmdline}" $out/cmdline.txt

    # LINUX KERNEL + INITRD
    cp ${rpifour2_system.config.system.build.toplevel}/kernel "$out/vmlinuz"
    cp ${rpifour2_system.config.system.build.toplevel}/initrd "$out/initrd"

    # PURGE EXISTING DTBS
    rm $out/*.dtb

    # LINUX MAINLINE DTBS
    for dtb in ${rpifour2_system.config.system.build.toplevel}/dtbs/{broadcom,}/bcm*.dtb; do
      cp $dtb "$out/"
    done
  '';

  tftp_parent_dir = pkgs.runCommandNoCC "build-tftp-dir" {} ''
    mkdir $out
    ln -s "${boot_dir}" "$out/${rpifour2_serial}"
  '';
in
{
  config = {
    fileSystems = {
      "/var/lib/nfs-data/rpifour2" = {
        # sudo zfs create -o mountpoint=legacy tank/var/rpifour2
        device = "tank/var/rpifour2";
        fsType = "zfs";
      };
      "/export/rpifour2" = {
        device = "/var/lib/nfs-data/rpifour2";
        options = [ "bind" ];
      };
      "/export/nix-db-export" = {
        device = "/nix/var/nix/db-export";
        options = [ "bind" ];
      };
      "/export/nix-store" = {
        device = "/nix/store";
        options = [ "bind" ];
      };
    };
    systemd.timers."nix-db-export" = {
      wantedBy = [ "timers.target" ];
      partOf = [ "nix-db-export.service" ];
      timerConfig.OnCalendar = "1 minute";
    };
    systemd.services."nix-db-export" = {
      wantedBy = [ "multi-user.target" ]; 
      #after = [ "network.target" ];
      description = "Make regular exports of the nix database.";
      # TODO: let systemd let this see /nix ?
      serviceConfig = {
        Type = "simple";
        ExecStart = (pkgs.writeScript "dump-db.sh" ''
          #!${pkgs.bash}/bin/bash
          set -x
          set -euo pipefail
          mkdir -p /nix/var/nix/db-export
          time ${pkgs.nix}/bin/nix-store --dump-db > /nix/var/nix/db-export/.snapshot.new
          mv /nix/var/nix/db-export/.snapshot.new /nix/var/nix/db-export/snapshot
        '');
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
        /export               192.168.1.0/24(fsid=0,ro,insecure,no_subtree_check)
        /export/nix-store     192.168.1.0/24(ro,nohide,insecure,no_subtree_check)
        /export/nix-db-export 192.168.1.0/24(ro,nohide,insecure,no_subtree_check)
        /export/rpifour2      192.168.1.0/24(rw,nohide,insecure,no_root_squash,no_subtree_check)
      '';
    };
  };
}
