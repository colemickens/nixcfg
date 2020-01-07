{ pkgs, modulesPath, ... }:

let
  lib = pkgs.lib;
  eth = "eth0";
  wg = "wg1";
  wg_port = 51820;
  externalIP = "192.168.1.117";
  external_range = "192.168.1.0/24";
  internalIP = "192.168.2.1";
  internal_range = "192.168.2.0/24";
in
{
  imports = [
    ../../modules/common.nix
#    ../../modules/pkgs-common.nix
    ../../modules/profile-interactive.nix
    ../../modules/user-cole.nix
#    ../../modules/profile-sway.nix

    ../../modules/mixin-unifi.nix
    ../../modules/mixin-plex-mpv.nix
    ../../modules/mixin-sshd.nix
    ../../modules/loremipsum-media/rclone-mnt.nix

    ../../modules/home-assistant

    "${modulesPath}/installer/cd-dvd/sd-image-raspberrypi4-new.nix"
  ];

  config = {
    nix.nixPath = [
      "nixpkgs=/home/cole/code/nixpkgs"
      "nixos-config=/home/cole/code/nixcfg/machines/raspberry/default.nix"
    ];

    documentation.nixos.enable = false;

    networking.hostName = "raspberry";

    environment.systemPackages = with pkgs; [
      cachix
      neovim
      ripgrep
      tmux htop
      plex-mpv-shim
      alsaTools alsaUtils pulsemixer
      git-crypt git
    ];

    ##############################
    networking = {
      wireless.enable = false;
      interfaces.eth0.ipv4.addresses = [
        { address = "192.168.1.117"; prefixLength = 16; }
      ];
      defaultGateway = "192.168.1.1";
      nameservers = [ "192.168.1.1" ];
    };
    hardware.opengl = {
      enable = true;
      setLdLibraryPath = true;
      package = pkgs.mesa_drivers;
    };
    hardware.deviceTree = {
      base = pkgs.device-tree_rpi;
      overlays = [ "${pkgs.device-tree_rpi.overlays}/vc4-fkms-v3d.dtbo" ];
    };

    boot.loader.raspberryPi.firmwareConfig = ''
      gpu_mem=192
      disable_overscan=1
      hdmi_drive=2
      dtparam=audio=on
    '';
    ##############################

    fileSystems = lib.mkForce {
      "/boot" = {
        device = "/dev/disk/by-label/FIRMWARE";
        fsType = "vfat";
        # we NEED this mounted
      };
      "/" = {
        device = "/dev/disk/by-label/NIXOS_SD";
        fsType = "ext4";
      };
    };

    networking.nat = {
      enable = true;
      internalInterfaces = [ wg ];
      internalIPs = [ internal_range ];
      externalInterface = eth;
      #externalIP = externalIP;
    };
    networking.firewall = {
      enable = true;
      allowedUDPPorts = [ wg_port ];
    };
    networking.wireguard.interfaces."${wg}" = {
      ips = [ internal_range ];
      listenPort = wg_port;
      privateKeyFile = "${../machines/raspberry/wg-server.key}";
      peers = [
        { allowedIPs = ["192.168.2.2/32"]; # cole-phone
          publicKey = "TVmP+Ov/RKECq98pCpoTAgJF9BKo/QrUUN+25dEnjR4="; }
        { allowedIPs = ["192.168.2.3/32"]; # buddie-phone
          publicKey = "UrVPH3QQhRNCsLfM21gv08PydwrIV6eGuStKG8mn/CI="; }
      ];
    };


    services.tor.enable = true;
    services.tor.hiddenServices = {
      "ssh" = {
        name = "ssh";
        map = [{ port = "22"; }];
        version = 3;
      };
      "homeass" = {
        name = "home-assistant";
        map = [{ port = 80; toPort = ha_port; }];
        version = 3;
      };
      "router" = {
        name = "router";
        map = [{ port = 443; toPort = "8443"; }];
        version = 3;
      };
    };


    environment.systemPackages = with pkgs; [
      mosquitto home-assistant-cli
    ];
    services.home-assistant = {
      enable = true;
      package = pkgs.home-assistant.override {
        extraPackages = ps: with ps; [
          colorlog
          zigpy
          getmac    # needed for "braviatv" type
          denonavr  # needed for "denonavr" type
          braviarc  # needed for "braviatv" type
          flux-led  # needed for light->flux_led type
          #bellows   # needed for zha (zigbee)
          #hbmqtt    # ??
        ];
      };
      port = 8123;
      config = {
        homeassistant = {
          name = "ChimeraHomeAssistant";
          time_zone = "US/Pacific";
          latitude = 47.6;
          longitude = -122.3;
          elevation = 60;
          unit_system = "metric";
          temperature_unit = "C";
          auth_providers = [
             # must be enabled to finish bootstrap/onboard:
             #{ type = "homeassistant"; }
             {
               type = "trusted_networks";
               trusted_networks = [ "127.0.0.1" external_range internal_range ];
               allow_bypass_login = true;
             }
          ];
        };
        frontend = {};
        mobile_app = {};
        http = {
          server_host = "0.0.0.0";
          server_port = ha_port;
        };
        cast = {
          media_player = { host = "192.168.1.70"; };
        };
        light = [
          {
            platform = "flux_led";
            devices = {
              "192.168.1.118" = {
                name = "mh_led";
                mode = "rgbw";
              };
            };
          }
        ];
        zwave = { usb_path = zwaveAdapter; };
        #zha = { usb_path = zigbeeAdapter; };
        media_player = [
          { name = "braviatv"; platform = "braviatv"; host = "192.168.1.115"; }
          { name = "denonavr"; platform = "denonavr"; host = "192.168.1.112"; }
        ];
      };
      lovelaceConfig = {
        title = "Chimera Home";
        views = [
          {
            title = "Chimera Devices";
            cards = [
              {
                title = "Living Room";
                type = "entities";
                entities = [
                  { name="Fireplace";
                    entity = "switch.ge_14291_in_wall_smart_switch_switch"; }
                  { name="TV";
                    entity = "media_player.denonavr"; }
                  { name="Receiver";
                    entity = "media_player.braviatv"; }
                ];
              }
              {
                title = "Bed Room";
                type = "entities";
                entities = [
                  { name = "Light Strip";
                    entity = "light.mh_led"; }
                ];
              }
            ];
          }
        ];
      };
      lovelaceConfigWritable = false;
    };
  };
}

