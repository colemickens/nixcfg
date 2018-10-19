{ ... }:

{
  imports = [
    ./common

    ./profile-sway.nix

    ./mixin-plex.nix
    ./mixin-samba.nix
    ./mixin-sshd.nix
    ./mixin-transmission.nix
    ./mixin-unifi.nix
  ];
}

