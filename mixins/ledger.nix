{ config, pkgs, ... }:

{
  config = {
    hardware.ledger.enable = true;

    home-manager.users.cole = { pkgs, ... }: {
      home.packages = with pkgs; [
        ledger_agent
        ledger-live-desktop
      ];
    };
  };
}
