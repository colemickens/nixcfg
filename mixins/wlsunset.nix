{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      services.wlsunset = {
        #enable = (pkgs.hostPlatform.system == "x86_64-linux");
        enable = true;
        longitude = "-122.3321";
        latitude = "47.6062";
        temperature.day = 6500;
        temperature.night = 3500;
      };
    };
  };
}
