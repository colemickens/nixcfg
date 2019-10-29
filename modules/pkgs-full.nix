{ pkgs, ... }:

{
  config = {
    # nixpkgs.overlays = [ (import ../overlay/default.nix) ];

    environment.systemPackages = with pkgs ; [
      # new random stuff
      ipfs
      rclone # ?
      bind
      ffmpeg
      linuxPackages.cpupower
      sshfs
      imgurbash2 spotify-tui xdg_utils

      # stuff I probably only need on NixOS:
      cryptsetup
      efibootmgr
      dmidecode

      # misc FSes:
      cifs-utils
      ms-sys
      ntfs3g

      # build tools:
      cmake gnumake gcc
      go rustup
      gdb lldb
      pkg-config

      # misc
      binutils.bintools
      file
      gptfdisk # essential?
      parted
      psmisc
      wipe

      # download tools
      aria2
      megatools
      youtube-dl
      plowshare
      streamlink
    ];
  };
}
