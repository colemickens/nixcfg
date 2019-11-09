{ pkgs }:

rec {
  rcloneConfigFile = pkgs.substituteAll {
    src = ./rclone.conf;
    rclone_archives   = ./sa/rclone-238701-9118db5df826.json;
    rclone_backups    = ./sa/rclone-238701-2f39d1bad234.json;
    rclone_movies     = ./sa/rclone-238701-d77283a08b9a.json;
    rclone_tvshows    = ./sa/rclone-238701-9a5c922143a1.json;
  };

  rclone-lim-mount = (pkgs.writeScriptBin "rclone-lim-mount" ''
    #!/usr/bin/env bash
    ${pkgs.rclone}/bin/rclone \
      --config ${rcloneConfigFile} \
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
      -v \
      mount ''${@}
  '');
}