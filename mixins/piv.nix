{ pkgs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        yubico-piv-tool
      ];
    };
  };
}
