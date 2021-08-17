{ config, lib, pkgs, ... }:

with lib;

let
  cfg = config.programs.zellij;
  cfgfmt = pkgs.formats.yaml { };
in {
  meta.maintainers = [ maintainers.colemickens ];

  options.programs.zellij = {
    enable = mkEnableOption "zellij";

    package = mkOption {
      type = types.package;
      default = pkgs.zellij;
      defaultText = literalExample "pkgs.zellij";
      description = "The package to use for zellij.";
    };

    settings = mkOption {
      type = with types;
        let
          prim = oneOf [ bool int str ];
          primOrPrimAttrs = either prim (attrsOf prim);
          entry = either prim (listOf primOrPrimAttrs);
          entryOrAttrsOf = t: either entry (attrsOf t);
          entries = entryOrAttrsOf (entryOrAttrsOf entry);
        in attrsOf entries // { description = "zellij configuration"; };
      default = { };
      example = literalExample ''
        {
          edit_mode = "vi";
          startup = [ "alias la [] { ls -a }" "alias e [msg] { echo $msg }" ];
          key_timeout = 10;
          completion_mode = "circular";
          no_auto_pivot = true;
        }
      '';
      description = ''
        Configuration written to
        <filename>~/.config/zellij/config.toml</filename>.
        </para><para>
        See <link xlink:href="https://www.zellij.sh/book/configuration.html" /> for the full list
        of options.
      '';
    };
  };

  config = mkIf cfg.enable {
    home.packages = [ cfg.package ];

    xdg.configFile."nu/config.toml" = mkIf (cfg.settings != { }) {
      source = cfgfmt.generate "zellij-config" cfg.settings;
    };
  };
}
