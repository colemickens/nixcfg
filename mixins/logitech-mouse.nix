{ pkgs, ... }:

{
  config = {
    services.ratbagd.enable = true;

    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        piper
      ];
    };
  };
}

