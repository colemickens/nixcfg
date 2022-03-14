# https://bitbucket.org/thefloweringash/alex-config/src/master/build-vm.nix

{ config, lib, pkgs, inputs, ... }:

let
  riscvpkgs = import "${inputs.riscvpkgs}" {
    system = pkgs.system;
    crossSystem = lib.systems.examples.riscv64;
    config = {
      overlays = [ inputs.riscv64.overlay ];
    };
  };
  riscvUboot = "${riscvpkgs.ubootQemuRiscv64Smode}/u-boot.bin";
  _sbi = p: riscvpkgs.opensbi.override { withPayload = builtins.trace "opensbi payload = ${p}" p; };
  riscvBios = p: "${_sbi p}/share/opensbi/lp64/generic/firmware/fw_jump.elf";

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
        #{ device = "/var/swapfile"; size = 16384; }
        { device = "/var/swapfile"; size = 2048; }
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
    systemd.timers.nix-gc.timerConfig.RandomizedDelaySec = lib.mkForce "1800";
  };

  mkBuildVM = vmpkgs: _config: (import "${vmpkgs}/nixos") {
    system = pkgs.system;
    configuration = _config // {
      nixpkgs.crossSystem = lib.systems.examples.riscv64;
    };
    #inherit system;
  };

in

{
  options = {
    services.buildVMs = lib.mkOption {
      default = { };
      type = lib.types.attrsOf (lib.types.submodule {
        options = {
          # TODO: this is really "local system"
          system = lib.mkOption {
            type = lib.types.enum [ "armv6l-linux" "armv7l-linux" "aarch64-linux" "riscv64-linux" ];
          };

          vmpkgs = lib.mkOption {
            type = lib.types.anything;
          };
          useInitrd = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };
          useAppend = lib.mkOption {
            type = lib.types.bool;
            default = true;
          };

          cpu = lib.mkOption {
            type = lib.types.str;
            default = "";
            example = "host,aarch64=off";
          };

          machine = lib.mkOption {
            type = lib.types.str;
            default = "virt";
            #default = "virt,highmem=off";
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
            default = { };
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
        vmNixos = mkBuildVM cfg.vmpkgs {
          imports = [
            buildVMCommonConfig
            builderConfig
            cfg.config
          ];
        };
        vmConfig = vmNixos.config;
        kernelTarget = vmNixos.pkgs.stdenv.hostPlatform.linux-kernel.target;
        closureInfoRelative = lib.removePrefix "${builtins.storeDir}/" vmConfig.system.build.closureInfo;
        defKernel = "${vmConfig.system.build.kernel}/${kernelTarget}";
        archMap = {
          "armv6l-linux" = { qemu = "qemu-system-arm";      bios = "default"; kernel = defKernel; };
          "armv7l-linux" = { qemu = "qemu-system-arm";      bios = "default"; kernel = defKernel; };
          "riscv64-linux" = { qemu = "qemu-system-riscv64"; bios = (riscvBios defKernel); kernel = defKernel; };
        };
        settings = archMap.${cfg.system};
        initrd = "${vmConfig.system.build.initialRamdisk}/initrd";
        append = "init=${vmConfig.system.build.toplevel}/init ${toString vmConfig.boot.kernelParams} closureInfo=${closureInfoRelative}";
      in
      {
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

            set -x
            ${settings.qemu} \
              -kernel "${settings.kernel}" \
              -bios "${settings.bios}" \
              ${lib.optionalString (cfg.useInitrd) "-initrd \"${initrd}\"" } \
              ${lib.optionalString (true /*cfg.useAppend*/) "-append \"${append}\"" } \
              ${lib.optionalString (cfg.kvm)            "-enable-kvm"} \
              ${lib.optionalString (cfg.mem != "")      "-m` ${cfg.mem}"} \
              ${lib.optionalString (cfg.smp != -1)      "-smp ${toString cfg.smp}"} \
              ${lib.optionalString (cfg.machine != "")  "-machine ${cfg.machine}"} \
              ${lib.optionalString (cfg.cpu != "")      "-cpu ${cfg.cpu}"} \
              -nographic \
              -drive if=none,id=hd0,file=$TMPDIR/scratch.raw,format=raw,werror=report,cache=unsafe \
              -fsdev local,id=state,path=$STATEDIR,security_model=none \
              -fsdev local,id=host-store,path=${builtins.storeDir},security_model=none,readonly=true \
              -device virtio-net-device,netdev=usernet \
              -netdev user,id=usernet${
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
