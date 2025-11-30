let
  user = "cole";
  name = "Cole Mickens";
  idno = 1000;
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
        # gpg card
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YAN+P0umXeSP/Cgd5ZvoD5gpmkdcrOjmHdonvBbptbMUbI/Zm0WahBDK0jO5vfJ/C6A1ci4quMGCRh98LRoFKFRoWdwlGFcFYcLkuG/AbE8ObNLHUxAwqrdNfIV6z0+zYi3XwVjxrEqyJ/auZRZ4JDDBha2y6Wpru8v9yg41ogeKDPgHwKOf/CKX77gCVnvkXiG5ltcEZAamEitSS8Mv8Rg/JfsUUwULb6yYGh+H6RECKriUAl9M+V11SOfv8MAdkXlYRrcqqwuDAheKxNGHEoGLBk+Fm+orRChckW1QcP89x6ioxpjN9VbJV0JARF+GgHObvvV+dGHZZL1N3jr8WtpHeJWxHPdBgTupDIA5HeL0OCoxgSyyfJncMl8odCyUqE+lqXVz+oURGeRxnIbgJ07dNnX6rFWRgQKrmdV4lt1i1F5Uux9IooYs/42sKKMUQZuBLTN4UzipPQM/DyDO01F0pdcaPEcIO+tp2U6gVytjHhZqEeqAMaUbq7a6ucAuYzczGZvkApc85nIo9jjW+4cfKZqV8BQfJM1YnflhAAplIq6b4Tzayvw1DLXd2c5rae+GlVCsVgpmOFyT6bftSon/HfxwBE4wKFYF7fo7/j6UbAeXwLafDhX+S5zSNR6so1epYlwcMLshXqyJePJNhtsRhpGLd9M3UqyGDAFoOQ== (none)"
        # bitwarden colemickens-sshkey
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIK7kPNqHXubFXq4k+15xz9ICn7IBd3Qfz7cawBsRzEO colemickens-sshkey"
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
