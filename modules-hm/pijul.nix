{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.pijul;
  tomlFormat = pkgs.formats.toml { };
in {
  meta.maintainers = [ hm.maintainers.colemickens ];

  options.programs.pijul = {
    enable = mkEnableOption "pijul";

    package = mkOption {
      type = types.package;
      default = pkgs.pijul;
      defaultText = literalExpression "pkgs.pijul";
      description = ''
        The pijul package to install.
      '';
    };

    settings = mkOption {
      type = tomlFormat.type;
      default = { };
      example = literalExpression ''
        {
          user = {
            name = "Pierre";
            full_name = "Pierre Pijul";
            email = "pierre@example.com";
          };
        }
      '';
      description = ''
        Configuration written to
        <filename>$XDG_CONFIG_HOME/pijul/config.toml</filename>.
        </para><para>
        See <link xlink:href="https://pijul.org/manual/getting_started.html" /> for the full
        list of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."pijul/config.toml" =
      mkIf (cfg.settings != { }) {
       source = tomlFormat.generate "config.toml" cfg.settings;
      };
  };
}
