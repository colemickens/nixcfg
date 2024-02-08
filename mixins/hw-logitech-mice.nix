{ pkgs, ... }:

{
  config = {
    # services.ratbagd.enable = true;

    hardware.logitech.wireless = {
      enable = true;
      enableGraphical = true;
    };

    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          # piper
        ];
      };
  };
}
