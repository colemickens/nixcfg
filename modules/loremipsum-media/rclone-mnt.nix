{ lib, pkgs, ... }:

let
  c = import ./common.nix { inherit pkgs; };
  target = "tvshows-ro:"; # pp
  #targets = [ "tvshows" "movies" ]; ## <-- pp
in {
  systemd.services = {
    rclone-mount = {
      description = "RCloneGoogDrv Mount Thing";
      path = with pkgs; [ fuse ];
      serviceConfig = {
        Type = "notify";
        StartLimitInterval = "60s";
        StartLimitBurst = 3;
        ExecStartPre = "${pkgs.coreutils}/bin/mkdir -p /mnt/${target}";
        ExecStart = c.rclone-lim-mount + " ${target}: /mnt/${target}";
        ExecStop = "${pkgs.fuse}/bin/fusermount -uz /mnt/${target}";
        Restart = "on-failure";
      };
      wantedBy = [ "default.target" ];
    };
  };
}

