{ lib, pkgs, ... }:

let
  rcloneConfigFile = pkgs.substituteAll {
    src = ./mixin-loremipsum-media-rclone.conf;
    rcloneServiceAccountFile = ./mixin-loremipsum-media-sa.json;
  };
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
      wantedBy = [ "multi-user.target" ];

      # TODO: for now local downloads are all ephemeral
      #requiresMountsFor = "/var/lib/localdata";
    }
  ];
  
  systemd.automounts = [
    {
      where = "${mergedMnt}";
      wantedBy = [ "multi-user.target" ];
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
    nginx = {
      enable = false;
      virtualHosts."azdev.westus2.cloudapp.azure.com" = {
	locations."/" = {
	  root = "/var/lib/data";
	  extraConfig = ''
	    dav_ext_methods PROPFIND OPTIONS;
	    dav_access user:rw group:rw all:rw;
	    autoindex on;
	    allow all;
	  '';
	};
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 ];

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

