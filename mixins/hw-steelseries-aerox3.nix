{ pkgs, ... }:

{
  config = {
    services.udev.packages = with pkgs; [ rivalcfg ];

    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [ rivalcfg ];
      };
  };
}
