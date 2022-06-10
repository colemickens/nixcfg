{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  netbootServer = "192.168.1.10";
  hn = config.networking.hostName;
in
{
  imports = [
    "${modulesPath}/installer/netboot/netboot.nix"
  ];
  config = {
    system.build.extras.nfsboot = (
      let
        top = config.system.build.toplevel;
        tb = config.system.build.towbootBuild;
        firmware = tb.config.Tow-Boot.outputs.extra.firmwareContents;
        eeprom = tb.config.Tow-Boot.outputs.extra.eepromFiles;
        piser = config.system.build.pi_serial;
      in
      pkgs.runCommandNoCC "netboot-env-${hn}" { } ''
        set -x
        mkdir $out

        # POPULATE NETBOOT WITH RPI-FW FILES
        cp -a "${firmware}"/* $out/

        # POPULATE NETBOOT WITH EEPROM UPDATE FILES
        cp -a "${eeprom}"/* $out/
        
        # POPULATE NETBOOT WITH EXTLINUX
        ${config.boot.loader.generic-extlinux-compatible.populateCmd} -d $out/ -c "${top}"
        
        # FIXUP "relative" extlinux.conf paths
        cp \
          $out/extlinux/extlinux.conf \
          $out/extlinux/extlinux.back
        sed -i 's|\.\./|${piser}/|g' $out/extlinux/extlinux.conf
      ''
    );
    boot.loader.timeout = lib.mkForce 10;
    fileSystems = {
      "/" = lib.mkForce {
        device = "${netbootServer}:/export/hostdata/${hn}";
        fsType = "nfs";
        options = [
          "x-systemd-device-timeout=20s"
          "nfsvers=3"
          "proto=tcp"
          "nolock"
          "rw" # so that it works in initrd with busybox's mount that only does nfs3
        ];
        neededForBoot = true;
      };
      "/nix/.ro-store" = lib.mkForce {
        device = "${netbootServer}:/export/nix-store";
        fsType = "nfs";
        options = [
          "x-systemd-device-timeout=20s"
          "nfsvers=3"
          "proto=tcp"
          "nolock"
          "ro" # so that it works in initrd with busybox's mount that only does nfs3
        ];
        neededForBoot = true;
      };
      "/nix/var/nix/shared" = lib.mkForce {
        device = "${netbootServer}:/export/nix-var-nix-shared";
        fsType = "nfs";
        options = [
          "x-systemd-device-timeout=20s"
          "nfsvers=3"
          "proto=tcp"
          "nolock"
          "ro" # so that it works in initrd with busybox's mount that only does nfs3
        ];
        neededForBoot = true;
      };
    };

    # TODO???
    hardware.bluetooth.powerOnBoot = false; # attempt to disable BT?

    boot = {
      postBootCommands = ''
        # After booting, register the contents of the Nix store
        # in the Nix database in the tmpfs.
        ${config.nix.package}/bin/nix-store --load-db < /nix/var/nix/shared/dump
        # nixos-rebuild also requires a "system" profile and an
        # /etc/NIXOS tag.
        touch /etc/NIXOS
        ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
      '';

      supportedFilesystems = lib.mkForce [ "vfat" "nfs" ];

      initrd.network.enable = true;
      initrd.network.flushBeforeStage2 = false;
      initrd.supportedFilesystems = lib.mkForce [ "vfat" "nfs" ];
    };
  };
}
