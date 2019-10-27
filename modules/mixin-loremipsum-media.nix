{ lib, pkgs, ... }:

let
  rcloneServiceAccountFile = pkgs.writeText "rclone-sa.json" ''
    {
      "type": "service_account",
      "project_id": "rclone-238701",
      "private_key_id": "1dc664bbc45912f8e4bed881d77abb214c736a39",
      "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvAIBADANBgkqhkiG9w0BAQEFAASCBKYwggSiAgEAAoIBAQDSWKWvEfI+cy4h\nEKcJlUsxyeE6UJYw1B3bsDNt5nugq73jhPolSvQbQw0UfzHtQNZ8Vcy7OJyyfH8v\nXlb5jv1ruWpXJgXpWz17ou2ipEJoKW77yEQp1BPcVQ0g8M4y5XwTzWobDQStC490\nGXLpZ4Xw/UDP2oLmmNuSngcn8TE11kBEdcBGtlOXYh8jQU94tMd+QAukHGjDv+OP\n5sfCeFizG6yZFUAzADfgmWIot7bWqFmaTcg7vy0C8pSOh9216VbAT9b2vKCi2Row\nDBcx1LTgB2AiWJKHhULzWPV6nKi3cnfom7ya1Dtxpsbcjyo+wRWZB5B9hfN8XZ67\nl2BlGg2HAgMBAAECggEAEbV34Xjb0aklyY/a2EIy7fKmnR+6vUqmZt/7PHXqk5jR\n6E1COBCK456uA7s/q09Jn3cjwOFfw+EaXhUNsn341PBrxQGE/uP5FaceZZJ5qsZO\nOzFdl73snCCm9c6ANaW/X/VryPI8Igt2nNolpAPcsXDI25b0bVCSL9JRHOo/792+\nKOWuWsBleBIX6N0/4IgbSOqvIEFfjxvnpMnpUnjUKA5In8BXHKIt/PsXsQLGXNbf\nKD5m3cTUjEmg3gAk5dy3gW2iAcJk2AZWFAoD9gObceC81ohkBnKAj2e2jq1Fm70Y\ni20vbzoPDQb+hJDAtIIfvtTNqBXLdLD9q5DOXMDoTQKBgQD49UilvM3bYvSrufDT\nqdIjkfBkH/iG/hs0DSvdrFpvKu0/1ApP/O8ro62dp8C97rz/89kHhpAA/kzZf+4m\nYrDS7UlfLKggxG0+391KyNiAmyjxsAYet6516Nad5ahDJi8+8WesF2NEF8yo66o+\nEQyfmFvT17E+NcmmTKt+RMcmKwKBgQDYS8X5CufVO+UKyUfpesRN/kS/tyeUQ+qq\nPEuxlEnqI/b+jM9qkEAc3TjBvQFNOosBWYyGy5vGSRN0UUv7NG40D0okZO/6x8tE\n38GruLGHXkNiEaowH/1zMiqm529KlivZG1A8A/ar/zY27Gd/J5yN5kqahwB1mGcu\nBSifFCHEFQKBgHawGW5KUKnix1qHTvTZ5UDn9n8FbuqMglOSY/NOk96jzG+9mxz/\nLNbVNZQPwafLBXfQvQsFb+nJUsHuZ48NRdeJII2rMIxOmPZ8q3dXwT+uuRpgHMrQ\nLvAvjQHB1zIMJkIPvKkijUSNRBjUIVltr2L2s/COyAUsh3Is4yVTjM35AoGAIljO\nBEEmFWdgdLkH0VysZZI2CpekElhCoGvYvUdGAYdahouHuG1VsP+0Lpe76C6eukUl\nGpakkvUxwKvUO/zUbzHqXSMmNJWbgsFheMpobo2ad61EcEX0MmHKAh0IQDjel6hN\nsmoStrddPZWGzdtVcfca67T6brIX2Gf7Tl+dCQ0CgYANu8zZVHmsXGxWa+Rb3sRp\nKR5NKcycDPZlfoq9Z/sFoSqlo4T3f8kJzKTwyCenmlylsGukprEx+HGgEhiGX9pZ\n5dS1pYzJKYwpL4l4KDiOZYmgiaPFaCTDKSb1HsiSXvf7pPYt89BLIPH7mPuMyoLB\nCEscX8E38lDo/yCej0g4sQ==\n-----END PRIVATE KEY-----\n",
      "client_email": "rclone@rclone-238701.iam.gserviceaccount.com",
      "client_id": "117022220503565942401",
      "auth_uri": "https://accounts.google.com/o/oauth2/auth",
      "token_uri": "https://oauth2.googleapis.com/token",
      "auth_provider_x509_cert_url": "https://www.googleapis.com/oauth2/v1/certs",
      "client_x509_cert_url": "https://www.googleapis.com/robot/v1/metadata/x509/rclone%40rclone-238701.iam.gserviceaccount.com"
    }
  '';
  rcloneConfigFile = pkgs.writeText "rclone.conf" ''
    [googdrv]
    type = drive
    service_account_file = ${rcloneServiceAccountFile}
    impersonate = johndough@loremipsumtechnologies.com

    [encgoogdrv]
    type = crypt
    remote = googdrv:encrypted_media
    filename_encryption = standard
    password = yIxCG1ljmAyqP9PH886G3ZgMzl3-d22DwQ
    password2 = MeX-eiwyvK06v0IAhJ1QFfli_1kxNPcW6Q

    directory_name_encryption = true
  '';
  flexgetConfigFile = ''
    web_server:
      bind: 0.0.0.0
      port: 3539
      run_v2: true
    schedules:
      - tasks: '*'
        interval:
    minutes: 10
  '';
  localData = "/var/lib/data-local";
  rcloneTgt = "googdrv:media";
  #rcloneTgt = "encgoogdrv:encrypted_media";
  rcloneMnt = "/var/lib/data-rclone";
  mergedMnt = "/var/lib/data";
in {
  environment.systemPackages = with pkgs; [ fuse mergerfs ];
  
  systemd.mounts = [
    { 
      after = [ "rclone-mount.service" ]; # TODO: non-string reference?
      what = "${localData}:${rcloneMnt}";
      where = "${mergedMnt}";
      type = "mergerfs"; # TODO: how to ensure is available?
      options = "defaults,sync_read,auto_cache,use_ino,allow_other,func.getattr=newest,category.action=all,category.create=ff";
      #WantedBy=multi-user.target

      # TODO: for now local downloads are all ephemeral
      #requiresMountsFor = "/var/lib/localdata";
    }
  ];
  
  services = {
    #flexget = {
    #  enable = true;
    #  config = flexgetConfigFile;
    #};
    samba = {
      shares = {
        googdrvsmb = {
          path = "/var/lib/data";
          browseable = "yes";
          public = "yes";
          "guest ok" = "yes";
          "read only" = "yes";
        };
      };
    };
  };

  systemd.services = {
    rclone-mount = {
      description = "RCloneGoogDrv Mount Thing";
      path = with pkgs; [ fuse ];
      serviceConfig = {
        Type = "notify";
        StartLimitInterval = "60s";
        StartLimitBurst = 3;
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p \"${rcloneMnt}\"";
        ExecStart = ''
          ${pkgs.rclone}/bin/rclone mount \
            --config '${rcloneConfigFile}' \
            --allow-other \
            --rc \
            --fast-list \
            --drive-skip-gdocs \
            --vfs-read-chunk-size=64M \
            --vfs-read-chunk-size-limit=2048M \
            --buffer-size=64M \
            --max-read-ahead=256M \
            --poll-interval=1m \
            --dir-cache-time=168h \
            --timeout=10m \
            --transfers=16 \
            --checkers=12 \
            --drive-chunk-size=64M \
            --fuse-flag=sync_read \
            --fuse-flag=auto_cache \
            --umask=002 \
            --syslog \
            -v \
            '${rcloneTgt}' '${rcloneMnt}'
          '';
        ExecStop = "${pkgs.fuse}/bin/fusermount -uz ${rcloneMnt}";
        Restart = "on-failure";
      };
      wantedBy = [ "default.target" ];
    };
  };
}

