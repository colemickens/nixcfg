{ pkgs, ... }:

{
  environment.systemPackages = with pkgs ; [
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

    # misc
    binutils.bintools
    file
    ffmpeg
    gptfdisk # essential?
    openssl
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

