{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.jj;
  tomlFormat = pkgs.formats.toml { };
in {
  meta.maintainers = [ hm.maintainers.colemickens ];

  options.programs.jj = {
    enable = mkEnableOption "jj";

    package = mkOption {
      type = types.package;
      default = pkgs.jj;
      defaultText = literalExpression "pkgs.jj";
      description = ''
        The jj package to install.
      '';
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      example = literalExpression ''
        {
          user = {
            name = "Martin";
            email = "martin@example.com";
          };
        }
      '';
      description = ''
        Configuration written to
        <filename>$HOME/.jjconfig</filename>.
        </para><para>
        See <link xlink:href="https://github.com/martinvonz/jj/blob/main/README.md#Installation" /> for the full
        list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    # xdg.configFile."jj/config.toml"
    home.file.".jjconfig" =
      mkIf (cfg.settings != { }) {
       source = tomlFormat.generate "jj.toml" cfg.settings;
      };
  };
}
