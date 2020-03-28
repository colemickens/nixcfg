{ config, lib, modulesPath, pkgs, ... }:
let
  hostKeyPath = pkgs.writeTextFile {
    name = "host_key";
    text = ''
      -----BEGIN OPENSSH PRIVATE KEY-----
      b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAAaAAAABNlY2RzYS
      1zaGEyLW5pc3RwMjU2AAAACG5pc3RwMjU2AAAAQQQDsFTxxSVrXx6Uovjgh4b0/ceSABde
      vVOtK0VwMFhlpcf0VEV5686Mmue1vtJX4L0uHKpsJtEBW8QJ/VhVnVn7AAAAqBPcyGcT3M
      hnAAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBAOwVPHFJWtfHpSi
      +OCHhvT9x5IAF169U60rRXAwWGWlx/RURXnrzoya57W+0lfgvS4cqmwm0QFbxAn9WFWdWf
      sAAAAhAO3aXAcuyXdQph+8HI3k2jAN07p9n66R051tsJnooLOPAAAACWNvbGVAeGVlcAEC
      AwQFBg==
      -----END OPENSSH PRIVATE KEY-----
    '';
  };
  download_store = pkgs.writeTextFile {
    executable = true;
    name = "kexec-nixos";
    text = ''
      #!${pkgs.stdenv.shell}
      export PATH=${pkgs.kexectools}/bin:${pkgs.cpio}/bin:$PATH
      set -x
      set -e

      dlhost="$(cat /proc/cmdline | sed -e 's/^.*dlhost=//' -e 's/ .*$//')"
      #dlhost="192.168.1.35.xip.io"

      dest="$(mktemp -d)"
      cd "$dest"
      ${pkgs.wget} "http://$dlhost/image.tar.gz"
      tar xvzf image.tar.gz
      cp $(readlink -f ./nix-store.squashfs) /nix-store.squashfs

      kexec -l $dest/kernel --initrd="$dest/initrd" --append="init=$(cat $dest/cmdline)"
      sync
      echo "executing kernel, filesystems will be improperly umounted"
      kexec -e
    '';
  };
in {

  imports = [ "${modulesPath}/installer/cd-dvd/sd-image-raspberrypi4.nix" ];
  config = {
    # boot.initrd.postMountCommands = ''
    #   mkdir -p /mnt-root/root/.ssh/
    #   cp /authorized_keys /mnt-root/root/.ssh/
    # '';

    documentation.nixos.enable = false;

    hardware.deviceTree = {
      base = pkgs.device-tree_rpi;
      overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
    };
    boot.loader.raspberryPi.enable = true;
    boot.loader.raspberryPi.firmwareConfig = ''
      gpu_mem=192
      disable_overscan=1
      hdmi_drive=2
      dtparam=audio=on
    '';

    ########################################################################################################################
    ########################################################################################################################
    # Don't build the GRUB menu builder script, since we don't need it
    # here and it causes a cyclic dependency.
    boot.loader.grub.enable = false;

    # !!! Hack - attributes expected by other modules.
    environment.systemPackages = [ pkgs.grub2_efi ]
      ++ (if pkgs.stdenv.hostPlatform.system == "aarch64-linux" then
        [ ]
      else [
        pkgs.grub2
        pkgs.syslinux
      ]);

    fileSystems."/" = lib.mkForce {
      fsType = "tmpfs";
      options = [ "mode=0755" ];
    };

    sdImage.compressImage = false;

    # In stage 1, mount a tmpfs on top of /nix/store (the squashfs
    # image) to make this a live CD.
    fileSystems."/nix/.ro-store" = {
      fsType = "squashfs";
      device = "../nix-store.squashfs";
      options = [ "loop" ];
      neededForBoot = true;
    };

    fileSystems."/nix/.rw-store" = {
      fsType = "tmpfs";
      options = [ "mode=0755" ];
      neededForBoot = true;
    };

    fileSystems."/nix/store" = {
      fsType = "overlay";
      device = "overlay";
      options = [
        "lowerdir=/nix/.ro-store"
        "upperdir=/nix/.rw-store/store"
        "workdir=/nix/.rw-store/work"
      ];
    };

    networking.useDHCP = true;
    networking.interfaces."eth0".useDHCP = true;
    boot.initrd.network.enable = true;
    boot.initrd.network.ssh = {
      enable = true;
      authorizedKeys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQCv76jivnmT678kYdL8J7yVVxhPhxyfL3Xp4jlCaEFded1uT+FXqBmYR5foOdB56L/QM/uCTWf0mbrwOYwYpkBx6cJTJqDMTlW0Mbys/UhEJo2U6U6fBSewuseiRRcUtvP+gOvsr1MmMi77xAHUkvDbeR1bLk9Eq2JoS5JMwD7T0ih2QVG3xheCgZml8avqfSXSDWOfqrui9VLzaxYhGe9M0Iv6yUA8gF8G2+iY9RkUBXvpCGjUlt3nd9yY/u4qRPsdCASt5l2AA61SUpA113QRkGfjAi4MDGwhnlUTYS0tawjIDrQqVuYqRp+1f0naKRCSDTXv87JB57GV9gbnFfmtzmFn2eTkJ7+PufiK7p763z6QIKfY8Qx9SBpOwKUi17n4y8VAXhsuOhiYmVapTx/QIIG8kag77NbxpD4bi+W3EufoSgi0ZS2CPBnzXxVENA/8Md+rWo2o8xhMmgMXZddxcEfZ00GvQSuGhtZApV6epIAzzrKckZrjwlmGJhk+uus= cole@xeep"
      ];
      hostECDSAKey = hostKeyPath;
    };

    # we must download and place squashfs
    # at the right time?
    systemd.services."download-store" = {
      description = "Download Store";
      path = with pkgs; [ wget bash ];
      serviceConfig = {
        Type = "simple";
        StartLimitInterval = "60s";
        StartLimitBurst = 3;
        ExecStart = "${download_store}";
        Restart = "on-failure";
      };
      after = [ "-.mount" ];
      wantedBy = [ "nix-ro-store.mount" ];
      requiredBy = [ "nix-ro-store.mount" ];
    };

    boot.initrd.availableKernelModules = [ "squashfs" "overlay" ];

    boot.initrd.kernelModules = [ "loop" "overlay" ];

    # Closures to be copied to the Nix store, namely the init
    # script and the top-level system configuration directory.
    # netboot.storeContents = [ config.system.build.toplevel ];

    # Create the squashfs image that contains the Nix store.
    # system.build.squashfsStore =
    #   pkgs.callPackage ../../../lib/make-squashfs.nix {
    #     storeContents = config.netboot.storeContents;
    #   };

    # Create the initrd
    # NO. Instead of creating it, we'll download it in a unit
    # that executes before the ro-store mount.
    # system.build.netbootRamdisk = pkgs.makeInitrd {
    #   inherit (config.boot.initrd) compressor;
    #   prepend = [ "${config.system.build.initialRamdisk}/initrd" ];

    #   contents = [{
    #     object = config.system.build.squashfsStore;
    #     symlink = "/nix-store.squashfs";
    #   }];
    # };

    # system.build.netbootIpxeScript = pkgs.writeTextDir "netboot.ipxe" ''
    #   #!ipxe
    #   kernel ${pkgs.stdenv.hostPlatform.platform.kernelTarget} init=${config.system.build.toplevel}/init initrd=initrd ${
    #     toString config.boot.kernelParams
    #   }
    #   initrd initrd
    #   boot
    # '';

    boot.loader.timeout = 10;

    boot.postBootCommands = ''
      # After booting, register the contents of the Nix store
      # in the Nix database in the tmpfs.
      ${config.nix.package}/bin/nix-store --load-db < /nix/store/nix-path-registration

      # nixos-rebuild also requires a "system" profile and an
      # /etc/NIXOS tag.
      touch /etc/NIXOS
      ${config.nix.package}/bin/nix-env -p /nix/var/nix/profiles/system --set /run/current-system
    '';
    ########################################################################################################################
    ########################################################################################################################

  };
}

