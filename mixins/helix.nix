{
  pkgs,
  config,
  inputs,
  ...
}: let
  tomlFormat = pkgs.formats.toml {};
  gen = cfg: (tomlFormat.generate "helix-languages.toml" cfg);
  helixUnstable = inputs.helix.outputs.packages.${pkgs.hostPlatform.system}.helix;
in {
  config = {
    home-manager.users.cole = {pkgs, ...}: {
      # xdg.configFile."helix/languages.toml".source = gen {
      #   languages = [
      #     {
      #       name = "nix";
      #       formatter = {command = "alejandra";};
      #     }
      #   ];
      # };
      xdg.configFile."helix/languages.toml".text = ''
        [[language]]
        name = "nix"
        # formatter = { command = "alejandra" }
        formatter = { command = "nixpkgs-fmt" }
      '';
      programs.helix = {
        # TODO: temp workaround for cross-arch eval with cargo-nix-integration
        enable = true;
        package =
          if pkgs.hostPlatform.system == "x86_64-linux"
          then helixUnstable
          else pkgs.helix;

        settings = {
          theme = "dark_plus";
          #theme = "gruvbox";
          #theme = "base16_terminal";

          editor = {
            line-number = "relative";
            mouse = true;
            indent-guides.render = true;
            cursorline = true;
            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };
            file-picker = {
              hidden = false;
            };
            gutters = ["diagnostics" "line-numbers" "spacer"];
            true-color = true;
            lsp = {
              display-messages = true;
            };
            whitespace = {
              render.space = "all";
              render.tab = "all";
              render.newline = "all";
              characters.space = "·";
              characters.nbsp = "⍽";
              characters.tab = "→";
              characters.newline = "⏎";
              characters.tabpad = "-";
            };
          };
        };
      };
    };
  };
}
