{ pkgs, modulesPath, inputs, ... }:
let
  lib = pkgs.lib;
  eth = "eth0";
  wg = "wg1";
in
{
  imports = [
    ../../mixins/common.nix
    ../../profiles/user.nix

    #UNDO ./modules/home-assistant
    #UNDO./modules/wireguard

    #./modules/drone.nix
    #./modules/cyclops.nix
    #./modules/netboot-server.nix
    #UNDO./modules/nginx.nix
    #UNDO./modules/postgres.nix

    #UNDO../../mixins/avahi-publish.nix
    #../../mixins/docker.nix
    #../../mixins/plex-mpv.nix
    ../../mixins/sshd.nix
    #UNDO../../mixins/srht-cronjobs.nix
    ../../mixins/tailscale.nix
    #UNDO../../mixins/unifi.nix

    #../../mixins/loremipsum-media/rclone-mnt.nix
    ./rpi4-uboot-mainline.nix
  ];

  config = {
    nix.nixPath = [];

    documentation.enable = false;
    documentation.doc.enable = false;
    documentation.info.enable = false;
    documentation.nixos.enable = false;

    networking.hostName = "rpione";
    services.udisks2.enable = false;
    networking.wireless.enable = false;
    networking.interfaces."${eth}".ipv4.addresses = [
      {
        address = "192.168.1.2";
        prefixLength = 16;
      }
    ];
    networking.defaultGateway = "192.168.1.1";
    networking.nameservers = [ "192.168.1.1" ];
  };
}
