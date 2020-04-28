{ pkgs }:

{
  enable = true;
  longitude = "-122.3321";
  latitude = "47.6062";
  temperature.day = 6500;
  temperature.night = 3500;
  package = pkgs.redshift-wayland;
}
