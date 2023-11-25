{ pkgs
, config
, inputs
, ...
}:
let
  tomlFormat = pkgs.formats.toml { };
  gen = cfg: (tomlFormat.generate "helix-languages.toml" cfg);
  # helixUnstable = inputs.helix.outputs.packages.${pkgs.stdenv.hostPlatform.system}.helix;
  # _helixPkg = helixUnstable;
  _helixPkg = pkgs.helix;
in
{
  config = {
    nixpkgs.overlays = [
      (final: prev: {
        helix = inputs.helix.packages.${pkgs.stdenv.hostPlatform.system}.helix;
      })
    ];
    home-manager.users.cole = { pkgs, ... }: {
      # xdg.configFile."helix/languages.toml".source = gen {
      #   languages = [
      #     {
      #       name = "nix";
      #       formatter = {command = "alejandra";};
      #     }
      #   ];
      # };
      xdg.configFile."helix/themes/zed_onedark_custom.toml".text = ''
        inherits = "zed_onedark"

        "ui.statusline.inactive" = { fg = "#546178", bg = "#21252B" }
        "ui.statusline" = { bg = "#181a1f" }
      '';
      # "ui.statusline" = "#000000"
      # "ui.statusline.inactive" = "#000000"
      xdg.configFile."helix/languages.toml".text = ''
        [language-server.nu-lsp]
        command = "nu"
        args = [ "--lsp" ]
        
        [[language]]
        name = "nix"
        auto-format = true
        formatter = { command = "nixpkgs-fmt" }

        [[language]]
        name = "nu"
        language-servers = [ "nu-lsp" ]
      '';
      programs.helix = {
        # TODO: temp workaround for cross-arch eval with cargo-nix-integration
        enable = true;
        package = _helixPkg;

        settings = {
          # see "custom..." blah blah stuff for overriding the bar on a given theme to give extra contrast:
          # TODO: add "Modern Dark" from modern VSCode to Helix
          theme = "catppuccin_mocha";

          editor = {
            auto-pairs = false;
            bufferline = "always";
            color-modes = true;
            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };
            cursorcolumn = true;
            cursorline = true;
            gutters = [
              "diagnostics"
              "line-numbers"
              "spacer"
              "diff"
            ];
            file-picker = {
              hidden = false;
            };
            indent-guides = {
              render = true;
              character = "│";
            };
            line-number = "relative";
            lsp = {
              display-messages = true;
            };
            mouse = true;
            rulers = [ 80 120 ];
            statusline = {
              left = [
                "mode"
                "spinner"
                "version-control"
                "file-name"
                "file-modification-indicator"
                "read-only-indicator"
              ];
              center = [ ];
              right = [
                "register"
                "file-type"
                "diagnostics"
                "selections"
                "position"
                "position-percentage"
              ];
            };
            true-color = true;
            whitespace = {
              render.space = "all";
              render.tab = "all";
              render.newline = "all";
              characters.space = " ";
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
