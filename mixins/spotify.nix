{ pkgs, config, ... }:

{
  config = {
    sops.secrets."spotifypw.txt".owner = "cole";
    
    home-manager.users.cole = { pkgs, ... }: {
      services.spotifyd = {
        enable = true;
        settings.global = {
          device_name = "${config.networking.hostName}-spotifyd";
          username = "cole.mickens";
          password_cmd = "cat ${config.sops.secrets."spotifypw.txt".path}";
        };
      };

      home.packages = [
        pkgs.spotify-tui
      ];
    };
  };
}    