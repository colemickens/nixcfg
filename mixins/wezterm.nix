{ pkgs, config, ... }:

let
  ts = import ./_common/termsettings.nix { inherit pkgs; };
  font = ts.fonts.default;
  colors = ts.colors.default;

  # foot scales the font size?
  #fontSize = (builtins.ceil (ts.fonts.default.size / 1.25) - 1);
  fontSize = ts.fonts.default.size;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.wezterm = {
        enable = true;
        settings = ''
        '';
      };
    };
  };
}
