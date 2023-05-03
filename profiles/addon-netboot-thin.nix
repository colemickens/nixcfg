# original source: https://gitlab.cri.epita.fr/cri/infrastructure/nixpie/-/blob/master/lib/make-squashfs.nix

{ modulesPath, config, lib, pkgs, ... }:

with lib;

let
  cfg = config.netboot;
  imageName = "${config.networking.hostName}-netboot";
  stateDir = "nixnetboot";
  squashfsDownloadDir = "/var/lib/${stateDir}";
in
{
  options = {
    netboot = {
      enable = mkEnableOption "Set defaults for creating a netboot image";
      squashfsUrl = mkOption {
        type = types.str;
        default = "http://192.168.1.99/${config.networking.hostName}-squashfs";
      };
      squashfsCompression = mkOption {
        type = types.str;
        default = "gzip";
      };
      fallbackNameservers = mkOption {
        type = types.listOf types.str;
        default = [ "1.1.1.1" ];
        description = "List of backup nameservers to use.";
      };
      nix-store-rw.enable = mkEnableOption "Nix Store read-write partition mounting" // { default = true; };
    };
  };

  config = mkIf config.netboot.enable {
    # Don't build the GRUB menu builder script, since we don't need it
    # here and it causes a cyclic dependency.
    boot.loader.grub.enable = false;

    # !!! Hack - attributes expected by other modules.
    # environment.systemPackages = [ pkgs.grub2_efi pkgs.grub2 pkgs.syslinux ];

    fileSystems = {
      "/" = {
        fsType = "tmpfs";
        options = [ "mode=0755" "size=80%" ];
      };

      # In stage 1, mount a tmpfs on top of /nix/store (the squashfs
      # image) to make this a live CD.
      # "/nix/.ro-store" = {
      #   fsType = "squashfs";
      #   device = "${cfg.squashfsDownloadDir}/squashfs.img";
      #   options = [ "loop" "x-systemd.after=squashfs-download.service" ];
      #   neededForBoot = true;
      # };

      # "/nix/.rw-store" = mkIf config.netboot.nix-store-rw.enable {
      #   fsType = "ext4";
      #   device = "/dev/disk/by-partlabel/nix-store-rw";
      #   options = [ "nofail" "x-systemd.device-timeout=15s" ];
      #   neededForBoot = true;
      # };

      # "/nix/store" = {
      #   fsType = "overlay";
      #   device = "overlay";
      #   options = [
      #     "lowerdir=/nix/.ro-store"
      #     "upperdir=/nix/.rw-store/store"
      #     "workdir=/nix/.rw-store/work"
      #     "x-systemd.after=/nix/.ro-store"
      #     "x-systemd.after=/nix/.rw-store"
      #   ];
      # };
    };

    boot.initrd = {
      availableKernelModules = [
        # To mount /nix/store
        "squashfs"
        "overlay"

        # SATA support
        "ahci"
        "ata_piix"
        "sata_inic162x"
        "sata_nv"
        "sata_promise"
        "sata_qstor"
        "sata_sil"
        "sata_sil24"
        "sata_sis"
        "sata_svw"
        "sata_sx4"
        "sata_uli"
        "sata_via"
        "sata_vsc"

        # NVMe
        "nvme"

        # Virtio (QEMU, KVM, etc.) support
        "virtio_pci"
        "virtio_blk"
        "virtio_scsi"
        "virtio_balloon"
        "virtio_console"
        "virtio_net"

        # Network support
        "ecb"
        "arc4"
        "bridge"
        "stp"
        "llc"
        "ipv6"
        "bonding"
        "8021q"
        "ipvlan"
        "macvlan"
        "af_packet"
        "xennet"
        "e1000e"
        "igc"
      ];
      kernelModules = [
        "loop"
        "overlay"
      ];
    };

    boot.initrd.systemd = {
      contents."/etc/protocols".source = config.environment.etc.protocols.source;
      mounts = [
        {
          what = "${squashfsDownloadDir}/squashfs.img";
          type = "squashfs";
          where = "/sysroot/nix/.ro-store";
          options = "";
          wantedBy = [ "local-fs.target" ];
          before = [ "local-fs.target" ];
          wants = [ "squashfs-download.service" ];
          after = [ "squashfs-download.service" ];
          unitConfig.IgnoreOnIsolate = true;
        }
        {
          where = "/sysroot/nix/store";
          what = "overlay";
          type = "overlay";
          options = "lowerdir=/sysroot/nix/.ro-store,upperdir=/sysroot/nix/.rw-store/store,workdir=/sysroot/nix/.rw-store/work";
          wantedBy = [ "local-fs.target" ];
          before = [ "local-fs.target" ];
          requires = [ "sysroot-nix-.ro\\x2dstore.mount" "rw-store.service" ];
          after = [ "sysroot-nix-.ro\\x2dstore.mount" "rw-store.service" ];
          unitConfig.IgnoreOnIsolate = true;
        }
      ];
      services = {
        rw-store = {
          after = [ "sysroot-nix-.rw\\x2dstore.mount" ];
          unitConfig.DefaultDependencies = false;
          serviceConfig = {
            Type = "oneshot";
            ExecStart = "/bin/mkdir -p 0755 /sysroot/nix/.rw-store/store /sysroot/nix/.rw-store/work /sysroot/nix/store";
          };
        };
        "squashfs-download" = {
          unitConfig.DefaultDependencies = false;
          script = ''
            set -x
            set -e
            mkdir -p "${squashfsDownloadDir}"
          
            ip a || true
            wget \
              "${cfg.squashfsUrl}" \
              --show-progress \
              -O "${squashfsDownloadDir}/squashfs.img"

            ls -al ${squashfsDownloadDir}
          '';
          after = [ "network-online.target" ];
          requires = [ "network-online.target" ];
          before = [ "local-fs.target" ];
          wantedBy = [ "local-fs.target" ];
          serviceConfig = {
            Type = "oneshot";
            StateDirectory = stateDir;
          };
        };
      };
    };

    # TODO: unclear why I needed to write mount units by hand

    # TODO BUG:
    # systemd initrd doesn't contain `wget` even tho
    # I explicitly include it here...
    boot.initrd.systemd.extraBin."wget" = "${pkgs.wget}/bin/wget";
    boot.initrd.systemd.extraBin."ip" = "${pkgs.iproute2}/bin/ip";

    # Usually, stage2Init is passed using the init kernel command line argument
    # but it would be inconvenient to manually change it to the right Nix store
    # path every time we rebuild an image. We just set it here and forget about
    # it.
    # Also, we cannot directly reference the current system.build.toplevel, as
    # it would cause an infinite recursion, so we have to put it in another
    # system.build artefact, in this case our squashfs, and use it from
    # there
    boot.initrd.postMountCommands = ''
      export stage2Init=$(cat $targetRoot/nix/store/stage2Init)
    '';

    boot.postBootCommands = ''
      # After booting, register the contents of the Nix store
      # in the Nix database in the tmpfs.
      ${config.nix.package}/bin/nix-store --load-db < /nix/store/nix-path-registration

      # nixos-rebuild also requires a "system" profile and an
      # /etc/NIXOS tag.
      touch /etc/NIXOS
      ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
    '';

    ###
    ### Outputs from the configuration needed to boot.
    ###

    # Create the squashfs image that contains the Nix store.
    system.build.squashfs = pkgs.callPackage "${modulesPath}/../lib/make-squashfs.nix" {
      # name = "${imageName}.squashfs";
      comp = "${cfg.squashfsCompression}";
      storeContents = singleton config.system.build.toplevel;
      stage2Init = "${config.system.build.toplevel}/init";
    };

    # Using the prepend argument here for system.build.initialRamdisk doesn't
    # work, so we just create an extra initrd and concatenate the two later.
    system.build.extraInitrd = pkgs.makeInitrd {
      name = "extraInitrd";
      inherit (config.boot.initrd) compressor;

      contents = [
        {
          # Required by aria2.
          object =
            config.environment.etc."ssl/certs/ca-certificates.crt".source;
          symlink = "/etc/ssl/certs/ca-certificates.crt";
        }
      ];
    };

    # Concatenate the required initrds.
    system.build.initrd = pkgs.runCommand "initrd" { } ''
      cat \
        ${config.system.build.initialRamdisk}/initrd \
        ${config.system.build.extraInitrd}/initrd \
        > $out
    '';

    system.build.toplevel-netboot = pkgs.runCommand "${imageName}.toplevel-netboot" { } ''
      mkdir -p $out
      cp ${config.system.build.kernel}/bzImage $out/${imageName}_bzImage
      cp ${config.system.build.initrd} $out/${imageName}_initrd
      cp ${config.system.build.squashfs}/${config.system.build.squashfs.name} $out/${imageName}.squashfs
    '';
  };
}
