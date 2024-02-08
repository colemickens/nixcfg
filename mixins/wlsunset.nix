{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        services = {
          wlsunset = {
            enable = true;
            latitude = "47.608103";
            longitude = "-122.335167";
          };
        };
      };
  };
}
