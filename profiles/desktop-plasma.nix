{ pkgs, lib, config, inputs, ... }:

{
  imports = [
    ./gui.nix
  ];
  config = {
    services.xserver.enable = true;
    services.xserver.displayManager.plasma5.enable = true;
    services.xserver.desktopManager.sddm.enable = true;

    home-manager.users.cole = { pkgs, ... }: {
      home.sessionVariables = {
        MOZ_USE_XINPUT2 = "1";
      };
      home.packages = with pkgs; [
        # sway-related
        kedit
        konsole
      ];
    };
  };
}
