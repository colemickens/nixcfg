{ pkgs, config, ... }:

{
  config = {
    sops.secrets = {
      "spotifypw.txt" = {
        owner = "cole";
        sopsFile = ../secrets/encrypted/spotifypw.txt;
        format = "binary";
      };
    };

    home-manager.users.cole =
      { pkgs, ... }:
      {
        services.spotifyd = {
          enable = true;
          settings.global = {
            device_name = "${config.networking.hostName}-spotifyd";
            username = "cole.mickens";
            password_cmd = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."spotifypw.txt".path}";
          };
        };

        home.packages = [ pkgs.spotify-tui ];
      };
  };
}
