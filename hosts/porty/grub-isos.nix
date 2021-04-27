# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

let
  tailsVer = "4.18";
  tailsIso = builtins.fetchurl {
    url = "https://tails.interpipe.net/tails/stable/tails-amd64-${tailsVer}/tails-amd64-${tailsVer}.iso";
    sha256 = "0maj7hvgn7psxhx2nvn6aha89fc325g4b4bb4d4dpd1mlyv1wr1z";
  };
in {
  config = {
    # copy the iso(s) to the large /boot since / is encrypted!
    # TODO: develop this into an entire module that will auto-pop and auto-prune iso
    # maybe some scripting or copy mappings from others to know where kernel/initrds are
    
    boot.loader.grub.extraPrepareConfig = ''
      mkdir -p /boot/nix/store
      # track the files we "copied"
      if [[ ! -f "/boot/${tailsIso}" ]]; then
        cp "${tailsIso}" "/boot/${tailsIso}"
      fi
      # delete any /boot/nix/store paths that we didn't copy, basically
    '';

    # note, no /boot in the isofile name path since that's its mount point (prefix)
    boot.loader.grub.extraEntries = ''
      menuentry "[[tails-${tailsVer}]] [Crypto] + [Living Will]" {
        search --set=drive1 --fs-uuid 879F-1940
          set isofile="($drive1)/${tailsIso}"
          loopback loop $isofile
          linux (loop)/live/vmlinuz boot=live config live-media=removable nopersistence noprompt timezone=Etc/UTC splash noautologin module=Tails slab_nomerge slub_debug=FZP mce=0 vsyscall=none page_poison=1 init_on_free=1 mds=full,nosmt  quiet toram
          initrd (loop)/live/initrd.img
      }
    '';
  };
}
