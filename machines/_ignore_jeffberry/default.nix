{ pkgs, modulesPath, ... }:

let
  lib = pkgs.lib;
  eth = "eth0";
  wg = "wg1";
  wg_port = 51820;
  external_range = "192.168.1.0/24";
  internalIP = "192.168.2.1";
  internal_range = "192.168.2.0/24";
in {
  imports = [ ./sd-image-raspberrypi4-new.nix ./home-assistant ];

  config = {
    nix.nixPath = [ ];
    documentation.nixos.enable = false;
    networking.hostName = "jeffberry";
    environment.systemPackages = with pkgs; [ file ripgrep tmux htop ];

    #
    # USER CONFIG
    users.extraUsers."jeff" = {
      isNormalUser = true;
      home = "/home/jeff";
      description = "Jeff Mickens";
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YAN+P0umXeSP/Cgd5ZvoD5gpmkdcrOjmHdonvBbptbMUbI/Zm0WahBDK0jO5vfJ/C6A1ci4quMGCRh98LRoFKFRoWdwlGFcFYcLkuG/AbE8ObNLHUxAwqrdNfIV6z0+zYi3XwVjxrEqyJ/auZRZ4JDDBha2y6Wpru8v9yg41ogeKDPgHwKOf/CKX77gCVnvkXiG5ltcEZAamEitSS8Mv8Rg/JfsUUwULb6yYGh+H6RECKriUAl9M+V11SOfv8MAdkXlYRrcqqwuDAheKxNGHEoGLBk+Fm+orRChckW1QcP89x6ioxpjN9VbJV0JARF+GgHObvvV+dGHZZL1N3jr8WtpHeJWxHPdBgTupDIA5HeL0OCoxgSyyfJncMl8odCyUqE+lqXVz+oURGeRxnIbgJ07dNnX6rFWRgQKrmdV4lt1i1F5Uux9IooYs/42sKKMUQZuBLTN4UzipPQM/DyDO01F0pdcaPEcIO+tp2U6gVytjHhZqEeqAMaUbq7a6ucAuYzczGZvkApc85nIo9jjW+4cfKZqV8BQfJM1YnflhAAplIq6b4Tzayvw1DLXd2c5rae+GlVCsVgpmOFyT6bftSon/HfxwBE4wKFYF7fo7/j6UbAeXwLafDhX+S5zSNR6so1epYlwcMLshXqyJePJNhtsRhpGLd9M3UqyGDAFoOQ== (none)"
      ];
      hashedPassword = # nix run -f ~/code/nixpkgs mkpasswd --command mkpasswd -m sha-512
        "$6$J7DyTD7T1AgB$2diShcxoHT06bPmZ4IdAn8LdWIW0TfOvry7ODBEVd/lj9D6Ziu1u/DXSl.mJknvdLABp5h8TDW14Ne8ut6QtO1";
      shell = "${pkgs.bash}/bin/bash";
      extraGroups = [ "wheel" ];
      uid = 1000;
    };
    nix.trustedUsers = [ "jeff" ];

    #
    # FS CONFIG
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

    #
    # NETWORK CONFIG
    networking.wireless.enable = false;
    #networking.interfaces.eth0.ipv4.addresses = [{
    #  address = "192.168.1.2";
    #  prefixLength = 16;
    #}];
    networking.interfaces.eth0.useDHCP = true;
    networking.defaultGateway = "192.168.1.1";
    networking.nameservers = [ "192.168.1.1" ];

    #
    # MISC SYSTEM CONFIG
    boot.tmpOnTmpfs = true;
    boot.cleanTmpDir = true;
    boot.kernel.sysctl = {
      "fs.file-max" = 100000;
      "fs.inotify.max_user_instances" = 256;
      "fs.inotify.max_user_watches" = 500000;
    };
    i18n.defaultLocale = "en_US.UTF-8";
    security.sudo.wheelNeedsPassword = false;
    users.mutableUsers = false;

    #
    # WIREGUARD CONFIG
    networking.nat = {
      enable = true;
      internalInterfaces = [ wgdev ];
      internalIPs = [ internal_range ];
      externalInterface = eth;
    };
    networking.firewall = {
      enable = true;
      allowedUDPPorts = [ wg_port ];
      allowedTCPPorts = [ 22 ];
    };
    networking.wireguard.interfaces."${wgdev}" = {
      ips = [ internal_range ];
      listenPort = wg_port;
      privateKeyFile = "${./wg-server.key}";
      peers = [{
        allowedIPs = [ "192.168.2.2/32" ]; # jeff-phone
        publicKey = "TVmP+Ov/RKECq98pCpoTAgJF9BKo/QrUUN+25dEnjR4=";
      }];
    };

    #
    # SSHD CONFIG
    services.openssh.enable = true;
    services.openssh.passwordAuthentication = true;
    services.openssh.permitRootLogin = "no";

    #
    # TOR CONFIG
    # (reliable backdoor into network)
    services.tor.enable = true;
    services.tor.hiddenServices."ssh" = {
      name = "ssh";
      map = [{
        port = "22";
        toPort = "22";
      }];
      #privateKeyPath = "/home/cole/hs_ed25519_secret_key";
      version = 3;
    };
  };
}
