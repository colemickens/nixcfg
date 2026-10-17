{ inputs, lib, ... }:

let
  macSettings = {
    fonts = {
      regular.family = "Iosevka Fixed";
      bold.family = "Iosevka Fixed";
      italic.family = "Iosevka Fixed";
      bold-italic.family = "Iosevka Fixed";
    };
  };
  linuxSettings = {};
in
{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        programs = {
          rio = {
            enable = true;
            settings = (if pkgs.stdenv.hostPlatform.system == "aarch64-darwin" then macSettings else linuxSettings);
          };
        };
      };
  };
}
