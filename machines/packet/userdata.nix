#!nix
{ pkgs, ... }:

let
  buildScript = "https://raw.githubusercontent.com/colemickens/nixcfg/master/machines/packet/buildworld.sh";
  cachixFile = pkgs.writeText "config.dhall" ''
    { authToken =
    "eyJhbGciOiJIUzI1NiJ9.eyJkYXQiOjk5fQ.tHAHICKd7Q8S_HOB18nRqg_SrvakRv2HPkVBqYp4u_8"
, binaryCaches =
    [ { name =
          "nixpkgs-wayland"
      , secretKey =
          "ZsU/hF9ECgAWWxh+/AF6CcS9pvcyCYblDdPvp0RGQdDeXDFogvExGRWF6GvlK1Cmsd0SjgisTyxGGj1H0c4tgA=="
      }
    , { name =
          "colemickens"
      , secretKey =
          "ptS+iivESw5U/Jo8VyVBW2rZFTQ0hZRZW0VpyYKFsHKggZuf1qiVRPaoqoLvyxw9wMvqfPs2mCi27rjhXhoaXg=="
      }
    , { name =
          "nixpkgs-colemickens"
      , secretKey =
          "6ZUt338E6JcMUcZqDABLs30wIz2pzcZps7PVVrLxeTWY8t+EPk7vs8yIR+JTLmswd4hRFya/BAZ68Caz5tqT3A=="
      }
    , { name =
          "nixpkgs-kubernetes"
      , secretKey =
          "P/3GanqABwQU2hY7jzvqcHShYSR6BPgXwPkNqCzOiaIW1kxzhpzF8dsNkGRZw4nzoKOLZtPrPybH3SBxL/vYVA=="
      }
    , { name =
          "azure"
      , secretKey =
          "6AbwcrZTxK53SS6+CLAKji1e1ymzkMMzoXCy+y1L2gfVzRXqlR4KfB3xtX9vT8Ew3hVqHYK3owUyLC2ldbxBMg=="
      }
    ] : List { name : Text, secretKey : Text }
}
  '';

  packetApiToken = "j7oTgz7kxXe5p4CLxuin2P578iiHecSs";
  packetProjectId= "afc67974-ff22-41fd-9346-5b2c8d51e3a9";

  shutdownPacketScript = pkgs.writeScript "shutdownPacket" ''
    #!/usr/bin/env bash
    set -x
    devid="$(curl -s "https://metadata.packet.net/2009-04-04/meta-data/instance-id")"
    echo curl -X DELETE -H "X-Auth-Token: ${packetApiToken}" \
      "https://api.packet.net/devices/$devid"
  '';

  buildworldScript = pkgs.writeScript "buildworld" ''
    #!/usr/bin/env bash
    set -x
    mkdir -p /home/cole/.config/cachix
    rm "/home/cole/.config/cachix/cachix.dhall"
    cp "${cachixFile}" "/home/cole/.config/cachix/cachix.dhall"
    curl --proto '=https' --tlsv1.2 -sSf "${buildScript}" | sh
  '';
in
{
  config = {
    nix.trustedUsers = [ "root" "cole" ];
    systemd.services.buildworld = {
      description = "buildworld";
      path = with pkgs; [ bash nix git jq curl cachix openssh ripgrep gnutar gzip gawk ];
      serviceConfig = {
        User = "cole";
        Type = "simple";
        ExecStart = "${buildworldScript}";
        ExecStopPost = "${shutdownPacketScript}";
        Restart = "on-failure";
      };
      wantedBy = [ "default.target" ];
      wants = [ "network-online.target" ];
      after = [ "network-online.target" ];
    };
    users.extraGroups."cole".gid = 1000;
    users.extraUsers."cole" = {
      isNormalUser = true;
      home = "/home/cole";
      description = "Cole Mickens";
      openssh.authorizedKeys.keys = ["ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC9YAN+P0umXeSP/Cgd5ZvoD5gpmkdcrOjmHdonvBbptbMUbI/Zm0WahBDK0jO5vfJ/C6A1ci4quMGCRh98LRoFKFRoWdwlGFcFYcLkuG/AbE8ObNLHUxAwqrdNfIV6z0+zYi3XwVjxrEqyJ/auZRZ4JDDBha2y6Wpru8v9yg41ogeKDPgHwKOf/CKX77gCVnvkXiG5ltcEZAamEitSS8Mv8Rg/JfsUUwULb6yYGh+H6RECKriUAl9M+V11SOfv8MAdkXlYRrcqqwuDAheKxNGHEoGLBk+Fm+orRChckW1QcP89x6ioxpjN9VbJV0JARF+GgHObvvV+dGHZZL1N3jr8WtpHeJWxHPdBgTupDIA5HeL0OCoxgSyyfJncMl8odCyUqE+lqXVz+oURGeRxnIbgJ07dNnX6rFWRgQKrmdV4lt1i1F5Uux9IooYs/42sKKMUQZuBLTN4UzipPQM/DyDO01F0pdcaPEcIO+tp2U6gVytjHhZqEeqAMaUbq7a6ucAuYzczGZvkApc85nIo9jjW+4cfKZqV8BQfJM1YnflhAAplIq6b4Tzayvw1DLXd2c5rae+GlVCsVgpmOFyT6bftSon/HfxwBE4wKFYF7fo7/j6UbAeXwLafDhX+S5zSNR6so1epYlwcMLshXqyJePJNhtsRhpGLd9M3UqyGDAFoOQ== (none)"];
      #mkpasswd -m sha-512
      hashedPassword = "$6$k.vT0coFt3$BbZN9jqp6Yw75v9H/wgFs9MZfd5Ycsfthzt3Jdw8G93YhaiFjkmpY5vCvJ.HYtw0PZOye6N9tBjNS698tM3i/1";
      shell = "/run/current-system/sw/bin/bash";
      extraGroups = [ "wheel" "networkmanager" "kvm" "libvirtd" "docker" "transmission" "audio" "video" "sway" "sound" "pulse" "input" "render" ];
      uid = 1000;
      group = "cole";
    };
  };
}
