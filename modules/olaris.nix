# https://bitbucket.org/thefloweringash/alex-config/src/master/build-vm.nix

{ config, lib, pkgs, inputs, ... }:

let
  cfg = config.services.osiris;
in {
  options = {
    services.olaris = lib.mkOption {
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
            default = -1;
            example = 16;
          };

          mem = lib.mkOption {
            type = lib.types.str;
            default = "";
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
              ${lib.optionalString cfg.kvm "-enable-kvm"} \
              ${lib.optionalString (cfg.mem != "") "-m` ${cfg.mem}"} \
              ${lib.optionalString (cfg.smp != -1) "-smp ${cfg.smp}"} \
              ${lib.optionalString (cfg.machine != "") "-machine ${cfg.machine}"} \
              ${lib.optionalString (cfg.cpu != "") "-cpu ${cfg.cpu}"} \
              -nographic \
              -drive if=none,id=hd0,file=$TMPDIR/scratch.raw,format=raw,werror=report,cache=unsafe \
              -fsdev local,id=state,path=$STATEDIR,security_model=none \
              -fsdev local,id=host-store,path=${builtins.storeDir},security_model=none,readonly \
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
