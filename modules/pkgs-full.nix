{ pkgs, ... }:

{
  environment.systemPackages = with pkgs ; [
    # new random stuff
    ipfs
    rclone # ?

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
    ffmpeg_4
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
}
