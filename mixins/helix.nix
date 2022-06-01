{ pkgs, config, inputs, ... }:

let
  tomlFormat = pkgs.formats.toml { };
  gen = cfg: (tomlFormat.generate "helix-languages.toml" cfg);
  helixUnstable = inputs.helix.outputs.packages.${pkgs.system}.helix;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      xdg.configFile."helix/languages.toml".source = gen {
        nix = { auto-format = true; };
      };
      programs.helix = {

        # TODO: temp workaround for cross-arch eval with cargo-nix-integration
        enable = true;
        package =
          if pkgs.system == "x86_64-linux"
          then helixUnstable
          else pkgs.helix;

        settings = {

          theme = "dark_plus";
          #theme = "gruvbox";
          #theme = "base16_terminal";

          editor = {
            line-number = "relative";
            mouse = true;
            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };
            true-color = true;
            lsp = {
              display-messages = true;
              # whitespace = {
              #   render.space = "all";
              #   render.tab = "all";
              #   render.newline = "all";
              #   characters.space = "·";
              #   characters.tab = "→";
              #   characters.newline = "⏎";
              # };
            };
          };
        };
      };
    };
  };
}
