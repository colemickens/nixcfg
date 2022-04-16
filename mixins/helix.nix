{ pkgs, config, inputs, ... }:

let
  tomlFormat = pkgs.formats.toml { };
  gen = cfg: (tomlFormat.generate "helix-languages.toml" cfg);
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      xdg.configFile."helix/languages.toml".source = gen {
        nix = { auto-format = true; };
      };
      programs.helix = {

        # TODO: temp workaround for cross-arch eval with cargo-nix-integration
        #enable = true;
        enable = if pkgs.system == "x86_64-linux" then true else false;
        package =
          inputs.helix.outputs.packages.${pkgs.system}.helix;
        # if pkgs.system == "x86_64-linux"
        # then inputs.helix.outputs.packages.${pkgs.system}.helix
        # else inputs.helix.outputs.packages.${pkgs.system}.helix-native;
        # else pkgs.helix;

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
