{ lib, pkgs, config, ... }:

let
  c = rec {
    rcloneConfigFile = config.sops.secrets."rclone.conf".path;

    sops.secrets."rclone.conf" = {
      owner = "cole";
      group = "cole";
    };

    rclone-lim = pkgs.writeScriptBin "rclone-lim" ''
      #!/usr/bin/env bash
      ${pkgs.rclone}/bin/rclone --config "${rcloneConfigFile}" "''${@}"
    '';

    rclone-lim-mount = readonly: (pkgs.writeScriptBin "rclone-lim-mount" ''
      #!/usr/bin/env bash
      ${pkgs.rclone}/bin/rclone \
        --config ${rcloneConfigFile} \
        --fast-list \
        --drive-skip-gdocs \
        --vfs-read-chunk-size=64M \
        --vfs-read-chunk-size-limit=2048M \
        --vfs-cache-mode writes \
        --buffer-size=128M \
        --max-read-ahead=256M \
        --poll-interval=1m \
        --dir-cache-time=168h \
        --timeout=10m \
        --transfers=16 \
        --checkers=12 \
        --drive-chunk-size=64M \
        --fuse-flag=sync_read \
        --fuse-flag=auto_cache \
        ${if readonly then "--read-only \\" else "\\"}
        --umask=002 \
        -v \
        mount ''${@}
    '');

    rclone-lim-mount-all = (pkgs.writeScriptBin "rclone-lim-mount-all" ''
      #!/usr/bin/env bash
      set -x
      pids=()
      mnts=( "tvshows" "movies" "misc" "backups" "archives" )
      for m in "''${mnts[@]}"; do
        sudo fusermount -uz "''${HOME}/mnt/''$m"
      done
      for m in "''${mnts[@]}"; do
        mkdir -p "''${HOME}/mnt/''$m"
        sudo fusermount -u "''${HOME}/mnt/''$m"
        "${rclone-lim-mount}/bin/rclone-lim-mount" "''$m:" "''${HOME}/mnt/''$m" &
        trap "set +x; kill ''$!; sudo fusermount -uz ''${HOME}/mnt/''$m || true; rm -f ''${HOME}/mnt/''$m" EXIT
      done
      wait
    '');
  };
  mkMount = target: readonly: {
    description = "RCloneGoogDrv Mount Thing";
    path = with pkgs; [ fuse bash ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = [
        "-${pkgs.fuse}/bin/fusermount -uz /mnt/rclone/${target}"
        "${pkgs.coreutils}/bin/mkdir -p /mnt/rclone/${target}"
      ];
      ExecStart = "${c.rclone-lim-mount readonly}/bin/rclone-lim-mount --allow-other ${target}: /mnt/rclone/${target}";
      ExecStop = "${pkgs.fuse}/bin/fusermount -uz /mnt/rclone/${target}";
      Restart = "on-failure";
    };
    startLimitIntervalSec = 60;
    startLimitBurst = 3;
    wantedBy = [ "default.target" ];
  };
in
{
  systemd.services = {
    rclone_misc = mkMount "misc" true;
    rclone_tvshows = mkMount "tvshows" true;
    rclone_movies = mkMount "movies" true;

    rclone_archives = mkMount "archives" true;
    rclone_backups = mkMount "backups" true;

    # TODO: finish
    rclone_incoming = mkMount "incoming" false;
  };
}

