{ pkgs, ... }:
let
  kexec_nixos = pkgs.writeTextFile {
    executable = true;
    name = "kexec-nixos";
    text = ''
      #!${pkgs.stdenv.shell}
      export PATH=${pkgs.kexectools}/bin:${pkgs.cpio}/bin:$PATH
      set -x
      set -e

      dest="$(mktemp -d)"
      cd "$dest"
      ${pkgs.wget} "http://localhost.xip.io/image.tar.gz"
      tar xvzf image.tar.gz

      kexec -l $dest/kernel --initrd="$dest/initrd" --append="init=$(cat $dest/cmdline)"
      sync
      echo "executing kernel, filesystems will be improperly umounted"
      kexec -e
    '';
  };
in {
  imports = [
    "/home/colemickens/code/nixpkgs/nixos/modules/installer/cd-dvd/sd-image-raspberrypi4.nix"
  ];

  config = {
    boot.initrd.postMountCommands = ''
      mkdir -p /mnt-root/root/.ssh/
      cp /authorized_keys /mnt-root/root/.ssh/
      ${kexec_nixos}
    '';

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

