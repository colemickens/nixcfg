{
  config,
  pkgs,
  lib,
  ...
}:

{
  config = {
    services.frigate = {
      enable = true;
      hostname = "frigate.mickens.us";
      settings = {
        cameras = { };
      };
    };
  };
}
