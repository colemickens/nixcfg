let
  user = "deploy";
  name = "Deployer";
  idno = 2000;
in
{
  config = {
    nix.settings.trusted-users = [ user ];

    users.extraGroups."${user}".gid = idno;
    users.extraUsers."${user}" = {
      isNormalUser = true;
      home = "/home/${user}";
      description = name;
      openssh.authorizedKeys.keys = [
      ];
      #mkpasswd -m sha-512
      hashedPassword = "$6$k.vT0coFt3$BbZN9jqp6Yw75v9H/wgFs9MZfd5Ycsfthzt3Jdw8G93YhaiFjkmpY5vCvJ.HYtw0PZOye6N9tBjNS698tM3i/1";
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

        "ydotool"
      ];
      uid = idno;
      group = user;
    };
  };
}
