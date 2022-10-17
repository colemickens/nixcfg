{ pkgs, lib, config, inputs, ... }:

{
  config = {
    nix.settings.trusted-users = [ "cole" ];

    users.extraGroups."cole".gid = 1000;
    users.extraUsers."cole" = {
      isNormalUser = true;
      home = "/home/cole";
      description = "Cole Mickens";
      openssh.authorizedKeys.keys = (import ../data/sshkeys.nix);
      #mkpasswd -m sha-512
      hashedPassword = "$6$k.vT0coFt3$BbZN9jqp6Yw75v9H/wgFs9MZfd5Ycsfthzt3Jdw8G93YhaiFjkmpY5vCvJ.HYtw0PZOye6N9tBjNS698tM3i/1";
      extraGroups = [
        "wheel"
        "kvm" "libvirtd" "qemu-libvirtd" "docker"
        "audio" "video" "sound" "pulse"
        "input" "render" "dialout" "keys" "ipfs" "plugdev"
        "networkmanager" "scard" "tss"
        "tty" "users"
        "network" # ? networkctl
        "netdev" # actually networkctl
        "lxd" # lxd lxc waydroid
        "flashrom"
        "rtkit" # rtkit stuff
      ];
      uid = 1000;
      group = "cole";
    };
  };
}
