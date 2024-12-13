let
  user = "jeff";
  name = "Jeff Mickens";
  idno = 1001;
in
{
  config = {
    users.extraGroups."${user}".gid = idno;
    users.extraUsers."${user}" = {
      isNormalUser = true;
      home = "/home/${user}";
      description = name;
      openssh.authorizedKeys.keys = [
      ];
      #mkpasswd -m sha-512
      hashedPassword = "$6$xghqv29U0F8gEvs0$.OkfFIJS3vmyraTORU2cgSyvLgNkjPtg1nt0pGqcWyHhc3Spn0Sw4bvUwK1OYOWIIvLMUD7WXjW.NBZ4Yo7OF0";
      extraGroups = [
        "wheel"

        "kvm"
        "libvirtd"
        "qemu-libvirtd"
        "docker"
        "podman"

        "audio"
        "video"
        "sound"
        "pulse" # ??
        "input"
        "render"
        "dialout"
        "keys"
        "ipfs"
        "networkmanager"
        "scard"
        "tss"
        "tty"
        "users" # ??
        "network" # ? networkctl
        "netdev" # actually networkctl
        "lxd" # lxd lxc waydroid
        "flashrom"
        "rtkit" # rtkit stuff
        "adbusers"
      ];
      uid = idno;
      group = user;
    };
  };
}
