{ config, pkgs, modulesPath, ... }:

{
  # imports = [
  #   ../secrets
  # ];
  
  config = {
    environment.systemPackages = with pkgs; [
      wpa_supplicant_gui
    ];
    networking.wireless = {
      enable = true;
      userControlled.enable = true;
      iwd.enable = false;
      environmentFile = config.sops.secrets."wireless.env".path;
      networks = {
        # TODO: map these automatically
        "chimera-wifi".pskRaw = "@pskRaw_chimera_wifi@";
        "Mickey".pskRaw = "@pskRaw_Mickey@";
      };
    };
  };
}
