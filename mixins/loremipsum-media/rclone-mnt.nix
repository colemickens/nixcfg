{ lib, pkgs, config, ... }:

let
  c = import ./common.nix { inherit pkgs config; };
  mkMount = target: readonly: {
    description = "RCloneGoogDrv Mount Thing";
    path = with pkgs; [ fuse bash ];
    serviceConfig = {
      Type = "simple";
      StartLimitInterval = "60s";
      StartLimitBurst = 3;
      ExecStartPre = [
        "-${pkgs.fuse}/bin/fusermount -uz /mnt/rclone/${target}"
        "${pkgs.coreutils}/bin/mkdir -p /mnt/rclone/${target}"
      ];
      ExecStart = "${c.rclone-lim-mount readonly}/bin/rclone-lim-mount --allow-other ${target}: /mnt/rclone/${target}";
      ExecStop = "${pkgs.fuse}/bin/fusermount -uz /mnt/rclone/${target}";
      Restart = "on-failure";
    };
    wantedBy = [ "default.target" ];
  };
in {
  systemd.services = {
    rclone_misc = mkMount "misc" true;
    rclone_tvshows = mkMount "tvshows" true;
    rclone_movies  = mkMount "movies" true;

    rclone_archives  = mkMount "archives" true;
    rclone_backups  = mkMount "backups" true;

    # TODO: finish
    rclone_incoming  = mkMount "incoming" false;
  };
}

