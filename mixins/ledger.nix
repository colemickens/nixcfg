{ ... }:

{
  config = {
    hardware.ledger.enable = true;

    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          ledger-live-desktop
        ];
      };
  };
}
