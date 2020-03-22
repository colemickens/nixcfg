{ config, pkgs, modulesPath, ... }:

with pkgs.lib; {
  imports = [
    #"${nixpkgs.path}/nixos/modules/installer/netboot/netboot-minimal.nix"
    "${modulesPath}/installer/netboot/netboot-minimal.nix"
  ];

  config = {
    services.mingetty.autologinUser = mkForce "root";
    systemd.services.sshd.wantedBy = mkOverride 0 [ "multi-user.target" ];
    users.users.root.openssh.authorizedKeys.keys = [''
      ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YAN+P0umXeSP/Cgd5ZvoD5gpmkdcrOjmHdonvBbptbMUbI/Zm0WahBDK0jO5vfJ/C6A1ci4quMGCRh98LRoFKFRoWdwlGFcFYcLkuG/AbE8ObNLHUxAwqrdNfIV6z0+zYi3XwVjxrEqyJ/auZRZ4JDDBha2y6Wpru8v9yg41ogeKDPgHwKOf/CKX77gCVnvkXiG5ltcEZAamEitSS8Mv8Rg/JfsUUwULb6yYGh+H6RECKriUAl9M+V11SOfv8MAdkXlYRrcqqwuDAheKxNGHEoGLBk+Fm+orRChckW1QcP89x6ioxpjN9VbJV0JARF+GgHObvvV+dGHZZL1N3jr8WtpHeJWxHPdBgTupDIA5HeL0OCoxgSyyfJncMl8odCyUqE+lqXVz+oURGeRxnIbgJ07dNnX6rFWRgQKrmdV4lt1i1F5Uux9IooYs/42sKKMUQZuBLTN4UzipPQM/DyDO01F0pdcaPEcIO+tp2U6gVytjHhZqEeqAMaUbq7a6ucAuYzczGZvkApc85nIo9jjW+4cfKZqV8BQfJM1YnflhAAplIq6b4Tzayvw1DLXd2c5rae+GlVCsVgpmOFyT6bftSon/HfxwBE4wKFYF7fo7/j6UbAeXwLafDhX+S5zSNR6so1epYlwcMLshXqyJePJNhtsRhpGLd9M3UqyGDAFoOQ== (none)
    ''];

    # system.build = rec {
    #   image =
    #     pkgs.runCommand "image" { buildInputs = [ pkgs.nukeReferences ]; } ''
    #       mkdir $out
    #       cp -r ${config.system.build.kernel}/Image $out/kernel
    #       cp ${config.system.build.netbootRamdisk}/initrd $out/initrd
    #       echo "init=${
    #         builtins.unsafeDiscardStringContext config.system.build.toplevel
    #       }/init ${toString config.boot.kernelParams}" > $out/cmdline
    #       nuke-refs $out/kernel
    #     '';
    #   kexec_tarball = pkgs.callPackage
    #     "/home/colemickens/code/nixpkgs/nixos/lib/make-system-tarball.nix" {
    #       storeContents = [{
    #         object = image;
    #         symlink = "/payload";
    #       }];
    #       contents = [ ];
    #     };
    # };

    boot.initrd.availableKernelModules = [ "squashfs" "overlay" ];

    boot.initrd.kernelModules = [ "loop" "overlay" ];

    # Closures to be copied to the Nix store, namely the init
    # script and the top-level system configuration directory.
    # netboot.storeContents = [ config.system.build.toplevel ];

    # Create the squashfs image that contains the Nix store.
    system.build.squashfsStore =
      pkgs.callPackage "${modulesPath}/../lib/make-squashfs.nix" {
        storeContents = config.netboot.storeContents;
      };

    system.build.fullball =
      pkgs.callPackage "${modulesPath}/../lib/make-system-tarball.nix" {
        storeContents = [
          {
            object = config.system.build.squashfsStore;
            symlink = "/nix-store.squashfs";
          }
          {
            object = pkgs.writeTextFile {
              name = "init-path.txt";
              text = ''
                ${
                  builtins.unsafeDiscardStringContext
                  config.system.build.toplevel
                }/init
              '';
            };
            symlink = "/init-path.txt";
          }
        ];
        contents = [ ];
      };

    # Create the initrd
    system.build.netbootRamdisk = pkgs.makeInitrd {
      inherit (config.boot.initrd) compressor;
      prepend = [ "${config.system.build.initialRamdisk}/initrd" ];

      contents = [{
        object = config.system.build.squashfsStore;
        symlink = "/nix-store.squashfs";
      }];
    };

    system.build.netbootIpxeScript = pkgs.writeTextDir "netboot.ipxe" ''
      #!ipxe
      kernel ${pkgs.stdenv.hostPlatform.platform.kernelTarget} init=${config.system.build.toplevel}/init initrd=initrd ${
        toString config.boot.kernelParams
      }
      initrd initrd
      boot
    '';

    boot.kernelPackages = pkgs.linuxPackages_rpi4;

    documentation.nixos.enable = false;

    hardware.deviceTree = {
      base = pkgs.device-tree_rpi;
      overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
    };
    boot.loader.raspberryPi.firmwareConfig = ''
      gpu_mem=192
      disable_overscan=1
      hdmi_drive=2
      dtparam=audio=on
    '';
  };
}

