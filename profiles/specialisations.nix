{ config, pkgs, inputs, ... }:

let
  desktops = [ "elementary" "gnome" "plasma" "sway" "sway-unwrapped" ];
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
    });
}