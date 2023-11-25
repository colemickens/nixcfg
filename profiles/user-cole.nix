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
        # /run/secrets/hydra_queue_runner_id_rsa.pub
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDCt/htvFKej/E03dE+4aYDe5HpbGhW7dJm+RBUl+gUFNyQcT9zwefQ43q+Du7KeFHbU6XB0/w/BKz/BrhdZbecC9eJ+3FN6n/yEwWtxPdcZOUyanYU0q0QvwFIFpHF75qWAwnssKLOm2gFYDJ+KKtbzXfVgJ/S3Rm6wCnAVusIYlir3laybgLeQfIPsaAJZTTaL9z8DBYcLQ7FUAgkK6qjr/fkACB056zvRJLQPPyw/I4+Jmc9Qhzj3iS4lrDe+OkpucGVmtn1ub06GOzZayqj11e2Ur/1ZDeWxcYkbfCSamlVTVmNdP+o/6pHbOzjz85TrAQqOlkTkV4T0zyqQ85Fdgmpw5T7q+NhUCnT/86fmqoo+wFl90tUq2uyNyAyiTwxwq4WQ/G6fGcbD1oZ85+XTpFuz1Rehfn/w/Jnq6jdj+Cnf3oIoUM4JCcgrMRtpSItbcKVIJoLrFF0sxA++7mSzXrdmfX8pXEopyF4YaZnwq1xMqgCeX1Yqhs/0KI3LJndnLjXR/AIENtFZpWFDj4KbcnDhg+0ZYxQWdArfhXJUFnkzge4hdTdUy0qcg7YLrtT8hNUdYNVIfUYBYlnuUztYRWAtMeVaXIy5gxMcoQCI16Tr0iN8tM9g7l8ibj6Iabmr4/Xb+BAgCMRDxIuxc7cWaZCT3io2qtH7WC33odv2w== hydra@azdev"
        # /run/secrets/github-colebot-sshkey.pub
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIPZvfolmlmFF8I+wwLbBRfDJjCIhpJjVBb5uQ9ePCgvP github-colebot-sshkey"
      ];
      #mkpasswd -m sha-512
      hashedPassword = "$6$k.vT0coFt3$BbZN9jqp6Yw75v9H/wgFs9MZfd5Ycsfthzt3Jdw8G93YhaiFjkmpY5vCvJ.HYtw0PZOye6N9tBjNS698tM3i/1";
      extraGroups = [
        "wheel"
        "kvm"
        "libvirtd"
        "qemu-libvirtd"
        "docker"
        "audio"
        "video"
        "sound"
        "pulse"
        "input"
        "render"
        "dialout"
        "keys"
        "ipfs"
        "networkmanager"
        "scard"
        "tss"
        "tty"
        "users"
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
