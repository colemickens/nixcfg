{ config, lib, pkgs, ... }:
with lib;

let
  boot-partition = config.mobile.outputs.u-boot.boot-partition;
  cfg = config.mobile-nixos.install-bootloader;
  install-bootloader-script = pkgs.writeScript "install-bootloader" ''
    #!${pkgs.zsh}/bin/zsh

    set -eu

    install -d /var/lib/mobile-nixos-bootloader

    print "Requested bootloader: ${boot-partition}"

    if [[ -e /var/lib/mobile-nixos-bootloader/current ]]
    then

      current=$(realpath /var/lib/mobile-nixos-bootloader/current)

      print "Current bootloader: $current"

      if [[ "${boot-partition}" = "$current" ]]
      then
        print "No bootloader update required"
        exit 0
      fi

    else
      print "No information about current bootloader"
    fi

    print "Deploying bootloader to ${cfg.target}"

    dd if="${boot-partition}/mobile-nixos-boot.img" of="${cfg.target}" bs=16M conv=fsync oflag=direct status=progress
    ln -T -f -s "${boot-partition}" /var/lib/mobile-nixos-bootloader/current
  '';

in {
  options.mobile-nixos.install-bootloader = {
    enable = mkOption {
      type = types.bool;
      default = false;
    };
    target = mkOption {
      type = types.path;
      default = "/dev/disk/by-label/mobile-nixos-boo";
      description = ''
        Target block device.
      '';
    };
  };
  config = mkIf cfg.enable {
    system.build.installBootLoader = install-bootloader-script;
  };
}
