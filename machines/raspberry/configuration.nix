{ pkgs, modulesPath, ... }:
let
  lib = pkgs.lib;
  eth = "eth0";
  wg = "wg1";
in
{
  imports = [
    ../../config-nixos/common.nix
    ../../config-home/users/cole/user.nix

    ./home-assistant

    ../../config-nixos/mixin-unifi.nix
    ../../config-nixos/mixin-sshd.nix
    ../../config-nixos/mixin-srht-cronjobs.nix
    ../../config-nixos/loremipsum-media/rclone-mnt.nix

    ./sd-image-raspberrypi4-new.nix
  ];

  config = {
    nix.nixPath = [];
    documentation.nixos.enable = false;
    networking.hostName = "raspberry";
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
    networking.useDHCP = false;
    networking.nat = {
      enable = true;
      internalInterfaces = [ wg ];
      internalIPs = [ "172.27.66.0/24" ];
      externalInterface = eth;
    };
    networking.firewall = {
      enable = true;
      allowedUDPPorts = [ 51820 ];
    };
    # networking.wireguard.interfaces."${wg}" = {
    #   ips = [ "172.27.66.1/24" ];
    #   listenPort = 51820;
    #   privateKeyFile = "${./wireguard/server.key}";
    #   peers = [
    #     {
    #       allowedIPs = [ "172.27.66.10/32" ];
    #       publicKey = builtins.readFile ./wireguard/clients/cole-phone/client.pub;
    #     }
    #     {
    #       allowedIPs = [ "172.27.66.11/32" ];
    #       publicKey = builtins.readFile ./wireguard/clients/cole-laptop/client.pub;
    #     }
    #     {
    #       allowedIPs = [ "172.27.66.20/32" ];
    #       publicKey = builtins.readFile ./wireguard/clients/bud-phone/client.pub;
    #     }
    #   ];
    # };
  };
}
