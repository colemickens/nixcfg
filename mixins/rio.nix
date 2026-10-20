{ inputs, lib, ... }:

let
  macSettings = {
    fonts = {
      regular.family = "Iosevka Term";
      bold.family = "Iosevka Term";
      italic.family = "Iosevka Term";
      bold-italic.family = "Iosevka Term";
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
