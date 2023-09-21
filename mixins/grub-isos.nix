{ config, pkgs, ... }:

# status:
# ??? may2022: no idea how old this is
# - ubuntu works
# - tails doesn't

# pretty sure tails is always a pita about loading any way other than what they expect
# debian's entire live-stuff is sketch af (nixos's is much simpler to read straight through)
# and tails's fork is even more... something, so I'm not surprised it's not cooperating

# TODO: yikes, this is pushing ISOs through cachix
# TODO: better to make a setup script that does the actual acquisition into place
# or not? idk think about this more

# TODO: in `boot.loader.grub.extraPrepareConfig`:
# - track the files we "copied"
# - delete any /boot/nix/store paths that we didn't copy, basically
# (this is used in other places for the bootloader files as well)

# TODO: add an optimization for if root is NOT encrypted (like in our case)
# and we can skip the copy of iso to /boot/...

let
  BOOT_FS_UUID = "879F-1940";

  isos = {
    "tails-4.18" = rec {
      iso = builtins.fetchurl {
        url = "https://tails.interpipe.net/tails/stable/tails-amd64-4.18/tails-amd64-4.18.iso";
        sha256 = "0maj7hvgn7psxhx2nvn6aha89fc325g4b4bb4d4dpd1mlyv1wr1z";
      };
      linux = "(loop)/live/vmlinuz boot=live config iso-scan/filename=${iso} findiso=${iso} live-media=removable nopersistence noprompt timezone=Etc/UTC splash noautologin module=Tails slab_nomerge slub_debug=FZP mce=0 vsyscall=none page_poison=1 init_on_free=1 mds=full,nosmt toram";
      initrd = "(loop)/live/initrd.img";
    };
    "ubuntu-21.04" = rec {
      iso = builtins.fetchurl {
        url = "https://mirror.pit.teraswitch.com/ubuntu-releases/21.04/ubuntu-21.04-desktop-amd64.iso";
        sha256 = "126zxiiwk7ffgq7sdm8c6kff4qqizb4c3qx5rykp1m1lidsgp5gs";
      };
      linux = "(loop)/casper/vmlinuz boot=casper iso-scan/filename=${iso} --";
      initrd = "(loop)/casper/initrd";
    };
  };
in
{
  config = {
    boot.loader.grub.extraPrepareConfig = (pkgs.lib.concatStrings ([
      ''
        mkdir -p /boot/nix/store
      ''
    ] ++ (builtins.attrValues (builtins.mapAttrs
      (k: v: ''
        if [[ ! -f "/boot/${v.iso}" ]]; then
          cp "${v.iso}" "/boot/${v.iso}"
        fi
      '')
      isos))));

    # note, no /boot in the isofile name path since that's its mount point (prefix)
    # the linux ... line is basically entirely copied from the <tails-iso>/isolinux/live.cfg
    boot.loader.grub.extraEntries = (pkgs.lib.concatStrings (builtins.attrValues (builtins.mapAttrs
      (k: v: ''
        menuentry "${k}" {
          rmmod tpm
          search --set=drive1 --fs-uuid ${BOOT_FS_UUID}
            set isofile="($drive1)/${v.iso}"
            loopback loop $isofile
            linux ${v.linux}
            initrd ${v.initrd}
        }
      '')
      isos)));
  };
}
