{ config, pkgs, inputs, ... }:

let
  desktops = [ "elementary" "gnome" "plasma" "sway" "sway-unstable" ];

  regularDesktop = desktopName: {
    configuration = ({config, pkgs, lib, inputs, ...}: {
      imports = [
        (./. + "/desktop-${desktopName}.nix")
      ];
      config = {
        boot.loader.grub.configurationName = "${desktopName}";
      };
    });
  };
  nvidiaDesktop = desktopName: {
    configuration = ({config, pkgs, lib, inputs, ...}: {
      imports = [
        (./. + "/desktop-${desktopName}.nix")
      ];
      config = {
        boot.loader.grub.configurationName = "${desktopName}";
        hardware.nvidia.modesetting.enable = true;
        services.xserver = {
          enable = true;
          videoDriver = "nvidia";
          displayManager.gdm.nvidiaWayland =
            (config.services.xserver.displayManager.gdm.enable == true);
        };
      };
    });
  };

  makeEntries = desktopName: [
    { name = "${desktopName}"; value = regularDesktop desktopName; }
    { name = "nvidia-${desktopName}"; value = nvidiaDesktop desktopName; }
  ];
  specials = builtins.listToAttrs (pkgs.lib.flatten (builtins.map makeEntries desktops));
in
{
  config.specialisation = specials;
}