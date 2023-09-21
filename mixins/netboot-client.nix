{ config, pkgs, lib, modulesPath, inputs, ... }:

let
  netbootServer = "192.168.1.10";
  hn = config.networking.hostName;

  # nfsvers = "4.1"; # when using systemd...
  nfsvers = "3"; # when using legacy busybox boot
  nfsproto = "tcp";

  # netbootServerPrefix = "${netbootServer}:/export" # busybox
  netbootServerPrefix = "${netbootServer}:/";
in
{
  imports = [
    "${modulesPath}/installer/netboot/netboot.nix"
  ];
  config = {

    boot.kernelParams = [
      # "systemd.log_level=debug"
      # "systemd.log_target=console"
      # "systemd.journald.forward_to_console=1"
      "systemd.setenv=SYSTEMD_SULOGIN_FORCE=1"
    ];

    # system.build.extras.nfsfirm = (
    #   let
    #     top = config.system.build.toplevel;
    #     hasTb = builtins.hasAttr "towbootBuild" config.system.build;
    #     tb = config.system.build.towbootBuild;
    #     diskImage = tb.config.Tow-Boot.outputs.diskImage;
    #   in
    #   pkgs.runCommand "nfsfirm-env-${hn}" { } (if hasTb then ''
    #     set -x
    #     mkdir $out
    #     cp -a "${diskImage}" $out/towboot.img
    #   '' else ''
    #     mkdir $out
    #     touch $out/none
    #   '')
    # );
    system.build.extras.nfsboot = (
      let
        top = config.system.build.toplevel;
        piser = config.system.build.sbc_serial;
        tci = config.system.build.extras.nfsboot-dbexport;

        hasTb_ = builtins.hasAttr "towbootBuild" config.system.build;
        tb = config.system.build.towbootBuild;
        hasTb = hasTb_ && (builtins.hasAttr "firmwareContents" tb.config.Tow-Boot.outputs.extra);
        firmware = tb.config.Tow-Boot.outputs.extra.firmwareContents;
        eeprom = tb.config.Tow-Boot.outputs.extra.eepromFiles; # TODO: "extraNetbootContents" ?? or should this just be in fwContents?
      in
      pkgs.runCommand "nfsboot-env-${hn}" { } (
        ''
          set -x
          mkdir $out
        
        '' + (if hasTb then ''
          # POPULATE NETBOOT WITH RPI-FW FILES
          cp -rs "${firmware}"/* $out/

          # POPULATE NETBOOT WITH EEPROM UPDATE FILES
          cp -rs "${eeprom}"/* $out/
        '' else
          ''
        '') +
        ''
          cp -a \
            "${pkgs.closureInfo { rootPaths = config.system.build.toplevel; }}" \
            $out/dbexport
        
          # POPULATE NETBOOT WITH EXTLINUX
          ${config.boot.loader.generic-extlinux-compatible.populateCmd} -d $out/ -c "${top}"
        
          # FIXUP "relative" extlinux.conf paths
          cp \
            $out/extlinux/extlinux.conf \
            $out/extlinux/extlinux.back
          sed -i 's|\.\./|${piser}/|g' $out/extlinux/extlinux.conf
        ''
      )
    );
    fileSystems = {
      "/" = lib.mkForce {
        device = "${netbootServerPrefix}/hostdata/${hn}";
        fsType = "nfs";
        options = [
          "x-systemd.idle-timeout=20s"
          # "nfsvers=${nfsvers}"
          # "proto=${nfsproto}"
          "nolock"
          "rw" # so that it works in initrd with busybox's mount that only does nfs3
        ];
        neededForBoot = true;
      };
      "/nix/.ro-store" = lib.mkForce {
        device = "${netbootServerPrefix}/nix-store";
        fsType = "nfs";
        options = [
          "x-systemd.idle-timeout=20s"
          # "nfsvers=${nfsvers}"
          # "proto=${nfsproto}"
          "nolock"
          "ro" # so that it works in initrd with busybox's mount that only does nfs3
        ];
        neededForBoot = true;
      };
      "/nixdb" = lib.mkForce {
        device = "${netbootServerPrefix}/nixdb/${hn}";
        fsType = "nfs";
        options = [
          "x-systemd.idle-timeout=20s"
          # "nfsvers=${nfsvers}"
          # "proto=${nfsproto}"
          "nolock"
          "ro" # so that it works in initrd with busybox's mount that only does nfs3
        ];
        neededForBoot = true;
      };
    };

    # TODO???
    hardware.bluetooth.powerOnBoot = false; # attempt to disable BT?

    system.activationScripts = {
      nixDbImport = {
        text = ''
          (set -x
            ls -al /nixdb
            cat /nixdb/registration | grep "${hn}"
            
            ${config.nix.package}/bin/nix-store --load-db < /nixdb/registration
            # ${config.nix.package}/bin/nix-store --verify-path $systemConfig

            ln -sf $systemConfig /run/current-system
            ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system

            touch /etc/NIXOS
          )
        '';
        deps = [ ];
      };
    };

    networking.useDHCP = false;
    networking.useNetworkd = true;
    systemd.network = config.boot.initrd.systemd.network;

    boot = {
      supportedFilesystems = lib.mkForce [ "vfat" "nfs" ];

      initrd = {
        kernelModules = [
          "nfs"
          "nfsv4"
        ];
        systemd = lib.mkMerge ([
          ({
            enable = true;
            network = {
              enable = true;
              links = {
                "99-defaults-myown" = {
                  matchConfig.OriginalName = "*";
                  linkConfig = {
                    NamePolicy = "keep kernel database onboard slot path";
                    AlternativeNamesPolicy = "database onboard slot path";
                    MACAddressPolicy = "persistent";
                  };
                };
              };
              networks = {
                "10-eth0" = {
                  matchConfig.Name = "eth0";
                  # addresses = [{ addressConfig = { Address = "${eth_ip}/${toString net_prefix}"; }; }];
                  networkConfig = {
                    Gateway = "192.168.1.1";
                    DNS = "192.168.1.1";
                    # DHCP = "ipv6";
                  };
                };
              };
            };
          })
          (lib.mkIf config.boot.initrd.systemd.enable {
            contents."/etc/protocols".source = config.environment.etc.protocols.source;
            mounts = [{
              where = "/sysroot/nix/store";
              what = "overlay";
              type = "overlay";
              options = "lowerdir=/sysroot/nix/.ro-store,upperdir=/sysroot/nix/.rw-store/store,workdir=/sysroot/nix/.rw-store/work";
              wantedBy = [ "local-fs.target" ];
              before = [ "local-fs.target" ];
              requires = [ "sysroot-nix-.ro\\x2dstore.mount" "sysroot-nix-.rw\\x2dstore.mount" "rw-store.service" ];
              after = [ "sysroot-nix-.ro\\x2dstore.mount" "sysroot-nix-.rw\\x2dstore.mount" "rw-store.service" ];
              unitConfig.IgnoreOnIsolate = true;
            }];
            services.rw-store = {
              after = [ "sysroot-nix-.ro\\x2dstore.mount" ];
              unitConfig.DefaultDependencies = false;
              serviceConfig = {
                Type = "oneshot";
                ExecStart = "/bin/mkdir -p 0755 /sysroot/nix/.rw-store/store /sysroot/nix/.rw-store/work /sysroot/nix/store";
              };
            };
          })
        ]);
      };

      loader = {
        timeout = lib.mkForce 10;
        generic-extlinux-compatible = {
          symlinkBootFiles = true;
        };
      };

      # TODO: might need this back for ethernet:
      extraModprobeConfig = ''
        options firmware_class path=${config.hardware.firmware}/lib/firmware
      '';

      initrd.network.enable = true;
      initrd.network.flushBeforeStage2 = false;
      initrd.supportedFilesystems = lib.mkForce [ "vfat" "nfs" ];
    };
  };
}
