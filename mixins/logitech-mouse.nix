{ pkgs, ... }:

{
  config = {
    services.libratbagd.enable = true;

    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        piper
      ];
    };
  };
}

