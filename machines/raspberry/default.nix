{ pkgs, modulesPath, ... }:

let
  lib = pkgs.lib;
  eth = "eth0";
  wg = "wg1";
in {
  imports = [
    ../../modules/common.nix
    ../../modules/user-cole.nix
    ../../modules/mixin-unifi.nix
    ../../modules/mixin-sshd.nix
    ../../modules/mixin-srht-cronjobs.nix
    #../../modules/loremipsum-media/rclone-mnt.nix

    ./home-assistant

    ./sd-image-raspberrypi4-new.nix

    # GUI
    ./gui.nix
    ../../modules/profile-sway-minimal.nix
  ];

  config = {
    nix.nixPath = [ ];
    documentation.nixos.enable = false;
    networking.hostName = "raspberry";
    environment.systemPackages = with pkgs; [ file ripgrep tmux htop ];

    networking.wireless.enable = false;
    networking.interfaces."${eth}".ipv4.addresses = [{
      address = "192.168.1.2";
      prefixLength = 16;
    }];
    networking.defaultGateway = "192.168.1.1";
    networking.nameservers = [ "192.168.1.1" ];
    networking.nat = {
      enable = true;
      internalInterfaces = [ wg ];
      internalIPs = [ "192.168.2.0/24" ];
      externalInterface = eth;
    };
    networking.firewall = {
      enable = true;
      allowedUDPPorts = [ 51820 ];
    };
    networking.wireguard.interfaces."${wg}" = {
      ips = [ "192.168.2.0/24" ];
      listenPort = 51820;
      privateKeyFile = "${./wireguard/server.key}";
      peers = [
        {
          allowedIPs = [ "192.168.2.2/32" ]; # cole-phone
          publicKey = builtins.readFile ./wireguard/cole-phone.pub;
        }
        {
          allowedIPs = [ "192.168.2.3/32" ]; # buddie-phone
          publicKey = builtins.readFile ./wireguard/bud-phone.pub;
        }
        {
          allowedIPs = [ "192.168.2.4/32" ]; # jeff-phone
          publicKey = builtins.readFile ./wireguard/jeff-phone.pub;
        }
      ];
    };

    fileSystems = lib.mkForce {
      "/boot" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
      };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };
    };
  };
}

