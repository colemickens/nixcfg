# https://bitbucket.org/thefloweringash/alex-config/src/master/build-vm.nix

{ config, lib, pkgs, inputs, ... }:

let
  buildVMCommonConfig = { config, lib, pkgs, modulesPath, ... }: {
    imports = [
      (modulesPath + "/profiles/qemu-guest.nix")
    ];

    config = {
      security.polkit.enable = false;

      documentation.enable = false;
      documentation.doc.enable = false;
      documentation.info.enable = false;
      documentation.nixos.enable = false;

      boot.loader.grub.enable = false;

      boot.kernelPackages = pkgs.linuxPackages_latest;

      boot.kernelParams = [ "boot.shell_on_fail" "console=ttyAMA0,115200" ];

      boot.kernelPatches = [
        {
          name = "enable-lpae";
          patch = null;
          extraConfig = ''
            ARM_LPAE y
          '';
        }
      ];

      systemd.tmpfiles.rules = [
        "d '/run/state/ssh' - root - - -"
      ];

      services.openssh = {
        enable = true;
        passwordAuthentication = false;

        hostKeys = [
          { path = "/run/state/ssh/ssh_host_ed25519_key"; type = "ed25519"; }
        ];
      };

      # Almost everything here was originally adapted from
      # nixpkgs/nixos/modules/virtualisation/qemu-vm.nix
      # nixpkgs/nixos/modules/installer/netboot.nix

      system.build.closureInfo = pkgs.closureInfo {
        rootPaths = [ config.system.build.toplevel ];
      };

      fileSystems = {
        "/" = {
          device = "/dev/disk/by-id/virtio-scratch";
          fsType = "ext4";
        };

        "/run/state" = {
          device = "state";
          fsType = "9p";
          options = [ "trans=virtio" "version=9p2000.L" "cache=loose" ];
        };

        "/nix/.host-store" = {
          device = "host-store";
          fsType = "9p";
          options = [ "trans=virtio" "version=9p2000.L" "cache=loose" ];
          neededForBoot = true;
        };
      };

      swapDevices = [
        { device = "/var/swapfile"; size = 16384; }
      ];

      boot.initrd.postMountCommands = ''
        mkdir -p $targetRoot/etc
        echo -n > $targetRoot/etc/NIXOS

        closureInfo=""
        for o in $(cat /proc/cmdline); do
          case $o in
            closureInfo=*)
              closureInfo=''${o#closureInfo=}
              ;;
          esac
        done

        if [ -n "$closureInfo" ]; then
          echo "Copying initial store from host store"
          mkdir -p $targetRoot/nix/store

          cat $targetRoot/nix/.host-store/$closureInfo/store-paths | \
            sed -e "s|^${builtins.storeDir}/|$targetRoot/nix/.host-store/|" | \
            while read path; do
              cp -a $path $targetRoot/nix/store
            done

          echo "Copied initial store"
        else
          echo "No closureInfo specified, continuing anyway..."
        fi
      '';

      boot.postBootCommands = ''
        # After booting, register the contents of the Nix store
        # in the Nix database in the scratch drive.
        if [[ "$(cat /proc/cmdline)" =~ closureInfo=([^ ]*) ]]; then
          echo "Registering initial store contents"
          closureInfo=''${BASH_REMATCH[1]}
          ${config.nix.package.out}/bin/nix-store --load-db < /nix/.host-store/$closureInfo/registration
        fi
      '';

      # Pretty heavy dependency for a builder.
      services.udisks2.enable = false;
    };
  };

  # https://github.com/NixOS/nixos-org-configurations/blob/ad7ff5d9b5440c2198b6b07ef2c1aa11e56a0f02/delft/build-machines-common.nix#L8-L14
  # but modified to set the free space set point to 64g, rather than upstream's 128g
  builderConfig = { pkgs, ... }: {
    nix.gc.automatic = true;
    nix.gc.dates = "*:45";
    nix.gc.options = ''--max-freed "$((64 * 1024**3 - 1024 * $(df -P -k /nix/store | tail -n 1 | ${pkgs.gawk}/bin/awk '{ print $4 }')))"'';

    # Randomize GC start times do we don't block all build machines at the
    # same time.
    systemd.timers.nix-gc.timerConfig.RandomizedDelaySec = "1800";
  };

  mkBuildVM = system: configuration: (import "${inputs.cross-pkgs}/nixos") {
    inherit system;
    inherit configuration;
  };

in

{
  options = {
    services.buildVMs = lib.mkOption {
      default = {};
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          # TODO: this is really "local system"
          system = lib.mkOption {
            type = lib.types.enum [ "armv6l-linux" "armv7l-linux" "aarch64-linux" ];
          };

          cpu = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "host,aarch64=off";
          };

          machine = lib.mkOption {
            type = lib.types.str;
            default = "virt,highmem=off";
          };

          smp = lib.mkOption {
            type = lib.types.int;
            example = 16;
          };

          mem = lib.mkOption {
            type = lib.types.str;
            example = "8g";
          };

          kvm = lib.mkEnableOption {
            default = true;
          };

          # TODO: what is the type of nixos config?
          config = lib.mkOption {
            default = {};
          };

          sshListenPort = lib.mkOption {
            default = null;
            type = lib.types.nullOr lib.types.port;
          };

          consoleListenPort = lib.mkOption {
            default = null;
            type = lib.types.nullOr lib.types.port;
          };
        };
      });
    };
  };

  config = {
    systemd.services = lib.mkMerge (lib.flip lib.mapAttrsToList config.services.buildVMs (name: cfg:
      let
        vmNixos = mkBuildVM cfg.system { imports = [
          buildVMCommonConfig builderConfig cfg.config
        ]; };
        vmConfig = vmNixos.config;
        kernelTarget = vmNixos.pkgs.stdenv.hostPlatform.linux-kernel.target;
        closureInfoRelative = lib.removePrefix "${builtins.storeDir}/" vmConfig.system.build.closureInfo;
        armMap = {
          "armv6l-linux" = "qemu-system-arm";
          "armv7l-linux" = "qemu-system-aarch64";
          "aarch64-linux" = "qemu-system-aarch64";
        };
        # TODO: assert that armv6 + kvm is unsupported
      in {
        "build-vm@${name}" = {
          wantedBy = [ "multi-user.target" ];
          script = ''
            set -euo pipefail

            export PATH=${lib.makeBinPath [ pkgs.qemu pkgs.qemu_kvm pkgs.utillinux pkgs.e2fsprogs ]}:$PATH

            : ''${STATEDIR:=/var/lib/build-vm-${name}}
            : ''${TMPDIR:=/tmp}

            fallocate -l 20G $TMPDIR/scratch.raw ########################### cfg
            mkfs.ext4 -L scratch $TMPDIR/scratch.raw

            # TODO: make this script more of a program and less of a
            # blob of systemd config mixed with nix mixed with shell

            serial=""
            ${lib.optionalString (cfg.consoleListenPort != null) ''
              if ! [ -t 1 ]; then
                serial="telnet:localhost:${toString cfg.consoleListenPort},server,nowait"
              fi
            ''}
            if [ -z "$serial" ]; then
              serial="chardev:char0"
            fi

              #-machine gic-version=3 \
              #-device virtio-rng-pci \

            ${armMap."${cfg.system}"} \
              -kernel ${vmConfig.system.build.kernel}/${kernelTarget} \
              -initrd ${vmConfig.system.build.initialRamdisk}/initrd \
              -append "init=${vmConfig.system.build.toplevel}/init ${toString vmConfig.boot.kernelParams} closureInfo=${closureInfoRelative}" \
              -m ${cfg.mem} -smp ${toString cfg.smp} \
              ${lib.optionalString cfg.kvm "-enable-kvm"} \
              -machine ${cfg.machine} \
              ${lib.optionalString (cfg.cpu != "") "-cpu ${cfg.cpu}"} \
              -nographic \
              -drive if=none,id=hd0,file=$TMPDIR/scratch.raw,format=raw,werror=report,cache=unsafe \
              -device virtio-blk-pci,drive=hd0,serial=scratch \
              -fsdev local,id=state,path=$STATEDIR,security_model=none \
              -device virtio-9p-pci,fsdev=state,mount_tag=state \
              -fsdev local,id=host-store,path=${builtins.storeDir},security_model=none,readonly \
              -device virtio-9p-pci,fsdev=host-store,mount_tag=host-store \
              -net nic,netdev=user.0,model=virtio \
              -netdev user,id=user.0${
                lib.optionalString (cfg.sshListenPort != null) ",hostfwd=tcp:0.0.0.0:${toString cfg.sshListenPort}-:22"
              } \
              -chardev stdio,mux=on,id=char0 \
              -mon chardev=char0,mode=readline \
              -serial "$serial" \
              "''${extra_args[@]}"
          '';

          serviceConfig = {
            DynamicUser = true;
            StateDirectory = "build-vm-%i";
            Type = "simple";
          };
        };
      }
    ));
  };
}
