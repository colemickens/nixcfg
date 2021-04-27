{ config, pkgs, ... }:

let
  BOOT_FS_UUID = "879F-1940";
  isos = {
    "tails-4.18" = {
      iso = builtins.fetchurl {
        url = "https://tails.interpipe.net/tails/stable/tails-amd64-4.18/tails-amd64-4.18.iso";
        sha256 = "0maj7hvgn7psxhx2nvn6aha89fc325g4b4bb4d4dpd1mlyv1wr1z";
      };
      linux = "(loop)/live/vmlinuz boot=live config iso-scan/filename=${tailsIso} findiso=${tailsIso} live-media=removable nopersistence noprompt timezone=Etc/UTC splash noautologin module=Tails slab_nomerge slub_debug=FZP mce=0 vsyscall=none page_poison=1 init_on_free=1 mds=full,nosmt toram";
      initrd = "(loop)/live/initrd.img";
    };
    "ubuntu-21.04" = {
      iso = builtins.fetchurl {
        url = "https://mirror.pit.teraswitch.com/ubuntu-releases/21.04/ubuntu-21.04-desktop-amd64.iso";
        sha256 = "0maj7hvgn7psxhx2nvn6aha89fc325g4b4bb4d4dpd1mlyv1wwww";
      };
      linux = "(loop)/casper/vmlinuz boot=casper iso-scan/filename=$isofile --";
      initrd = "(loop)/casper/initrd";
    };
  };
in {
  config = {
    # copy the iso(s) to the large /boot since / is encrypted!
    # TODO: develop this into an entire module that will auto-pop and auto-prune iso
    # maybe some scripting or copy mappings from others to know where kernel/initrds are
    
    boot.loader.grub.extraPrepareConfig = ''
      mkdir -p /boot/nix/store

      # FOR EACH...

      if [[ ! -f "/boot/${tailsIso}" ]]; then
        cp "${tailsIso}" "/boot/${tailsIso}"
      fi

      # TODO:
      # track the files we "copied"
      # delete any /boot/nix/store paths that we didn't copy, basically
      # (this is used in other places for the bootloader files as well)
    '';

    # note, no /boot in the isofile name path since that's its mount point (prefix)
    # the linux ... line is basically entirely copied from the <tails-iso>/isolinux/live.cfg
    boot.loader.grub.extraEntries = ''

      # FOR EACH...

      menuentry "${key}" {
        rmmod tpm
        search --set=drive1 --fs-uuid ${BOOT_FS_UUID}
          set isofile="($drive1)/${value.iso}"
          loopback loop $isofile
          linux ${value.linux}
          initrd ${value.initrd}
      }
    '';
  };
}
