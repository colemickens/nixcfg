{ lib, pkgs, config, ... }:

let
  c = import ./common.nix { inherit pkgs config; };
  mkMount = target: {
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
      ExecStart = "${c.rclone-lim-mount}/bin/rclone-lim-mount --allow-other ${target}: /mnt/rclone/${target}";
      ExecStop = "${pkgs.fuse}/bin/fusermount -uz /mnt/rclone/${target}";
      Restart = "on-failure";
    };
    wantedBy = [ "default.target" ];
  };
in {
  sops.secrets."rclone.conf" = {
    owner = "rclone";
    group = "rclone";
  };
  sops.secrets."rclone-reader-sa.json" = {
    owner = "rclone";
    group = "rclone";
  };
  sops.secrets."rclone-writer-sa.json" = {
    owner = "rclone";
    group = "rclone";
  };

  systemd.services = {
    rclone_tvshows = mkMount "tvshows";
    rclone_movies  = mkMount "movies";
  };
}

