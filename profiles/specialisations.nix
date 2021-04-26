{ config, pkgs, inputs, ... }:

let
  desktops = [ "elementary" "gnome" "plasma" "sway" "sway-unstable" ];
in
{
  config.specialisation = 
    pkgs.lib.genAttrs desktops (desktop: {
      configuration = {
        boot.loader.grub.configurationName = "${desktop}";
        imports = [
          (./. + "/desktop-${desktop}.nix")
        ];
      };
    })
    ++
    pkgs.lib.genAttrs desktops (desktop: {
      configuration = {
        boot.loader.grub.configurationName = "nvidia-${desktop}";
        imports = [
          (./. + "/desktop-${desktop}.nix")
          ({pkgs, config}: {
            config = {
              hardware.nvidia.modesetting.enable = true;
              services.xserver = {
                enable = true;
                driver = "nvidia";
                displayManager.gdm.nvidiaWayland = (config.displayManager.gdm.enable == true);
              };
            };
          });
        ];
      };
    });
}