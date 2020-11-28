{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      services.wlsunset = {
        #enable = (pkgs.system == "x86_64-linux");
        longitude = "-122.3321";
        latitude = "47.6062";
        temperature.day = 6500;
        temperature.night = 3500;
      };
    };
  };
}
