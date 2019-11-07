{ lib, pkgs, ... }:

#
#
#
# copy from sync.sh so we have a portable command nixos config
#
#
#
#

let
  rcloneConfigFile = pkgs.substituteAll {
    src = ./mixin-loremipsum-media-rclone.conf;
    rcloneServiceAccountFile = ./mixin-loremipsum-media-sa.json;
  };
  localData = "/var/lib/data-local";
  rcloneTgt = "google_drive_media_mnt:";
  rcloneMnt = "/var/lib/data";
in {
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
	    --read-only \
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

