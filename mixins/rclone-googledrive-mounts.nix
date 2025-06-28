{ pkgs, config, ... }:

let
  rcloneConfPath = config.sops.secrets."rclone.conf".path;

  c = rec {
    rclone-lim = pkgs.writeScriptBin "rclone-lim" ''
      #!${pkgs.bash}/bin/bash
      ${pkgs.rclone}/bin/rclone --config "${rcloneConfPath}" "''${@}"
    '';

    rclone-lim-mount =
      readonly:
      (pkgs.writeScriptBin "rclone-lim-mount" ''
        #!${pkgs.bash}/bin/bash
        ${pkgs.rclone}/bin/rclone \
          --config ${rcloneConfPath} \
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

    rclone-lim-mount-all = (
      pkgs.writeScriptBin "rclone-lim-mount-all" ''
        #!${pkgs.bash}/bin/bash
        set -x
        pids=()
        mnts=( "tvshows" "movies" "misc" "backups" "archives" )
        for m in "''${mnts[@]}"; do
          sudo fusermount -uz "''${HOME}/mnt/$m"
        done
        for m in "''${mnts[@]}"; do
          mkdir -p "''${HOME}/mnt/$m"
          sudo fusermount -u "''${HOME}/mnt/$m"
          "${rclone-lim-mount}/bin/rclone-lim-mount" "$m:" "''${HOME}/mnt/$m" &
          trap "set +x; kill $!; sudo fusermount -uz ''${HOME}/mnt/$m || true; rm -f ''${HOME}/mnt/$m" EXIT
        done
        wait
      ''
    );
  };
  mkMount = target: readonly: {
    description = "RCloneGoogDrv Mount Thing";
    path = with pkgs; [
      fuse3
      bash
    ];
    serviceConfig = {
      Type = "simple";
      ExecStartPre = [
        "-${pkgs.fuse3}/bin/fusermount3 -uz /mnt/rclone/${target}"
        "${pkgs.coreutils}/bin/mkdir -p /mnt/rclone/${target}"
      ];
      Environment = [ "PATH=${pkgs.fuse3}/bin:$PATH" ];
      ExecStart = "${c.rclone-lim-mount readonly}/bin/rclone-lim-mount --allow-other ${target}: /mnt/rclone/${target}";
      ExecStop = "${pkgs.fuse3}/bin/fusermount3 -uz /mnt/rclone/${target}";
      Restart = "on-failure";
    };
    startLimitIntervalSec = 60;
    startLimitBurst = 3;
    wantedBy = [ "default.target" ];
  };
in
{
  sops.secrets."rclone.conf" = {
    owner = "cole";
    group = "cole";
    sopsFile = ../secrets/encrypted/rclone.conf;
    format = "binary";
  };
  # sops.secrets."rclone-reader-sa.json" = {
  #   owner = "cole";
  #   group = "cole";
  #   sopsFile = ../secrets/encrypted/rclone-reader-sa.json;
  #   format = "binary";
  # };
  # sops.secrets."rclone-writer-sa.json" = {
  #   owner = "cole";
  #   group = "cole";
  #   sopsFile = ../secrets/encrypted/rclone-writer-sa.json;
  #   format = "binary";
  # };
  sops.secrets."rclone-personal-reader-sa.json" = {
    owner = "cole";
    group = "cole";
    sopsFile = ../secrets/encrypted/rclone-personal-writer-sa.json;
    format = "binary";
  };
  sops.secrets."rclone-personal-writer-sa.json" = {
    owner = "cole";
    group = "cole";
    sopsFile = ../secrets/encrypted/rclone-personal-writer-sa.json;
    format = "binary";
  };

  systemd.services = {
    # rclone-tvshows = mkMount "tvshows" true;
    # rclone-movies = mkMount "movies" true;
    # rclone-music = mkMount "music" true;

    rclone-testenc1 = mkMount "testenc1" false;

    rclone-misc = mkMount "misc" true;
    rclone-archives = mkMount "archives" true;
    rclone-backups = mkMount "backups" true;

    # TODO: finish
    # rclone-incoming = mkMount "incoming" false;
  };
}
