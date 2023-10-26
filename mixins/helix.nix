{ pkgs
, config
, inputs
, ...
}:
let
  tomlFormat = pkgs.formats.toml { };
  gen = cfg: (tomlFormat.generate "helix-languages.toml" cfg);
  # helixUnstable = inputs.helix.outputs.packages.${pkgs.stdenv.hostPlatform.system}.helix;
  # helixPkg = helixUnstable;
  helixPkg = pkgs.helix;
in
{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
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
        auto-format = true
        formatter = { command = "nixpkgs-fmt" }

        # [language-server.nuls]
        # command = "${pkgs.nuls}/bin/nuls"

        # [[language]]
        # name = "nu"
        # language-servers = [ "nuls" ]
      '';
      programs.helix = {
        # TODO: temp workaround for cross-arch eval with cargo-nix-integration
        enable = true;
        package =
          if pkgs.hostPlatform.system == "x86_64-linux"
          then helixPkg
          else pkgs.helix;

        settings = {
          # theme = "ayu_evolve";
          theme = "ayu_dark";
          # theme = "everblush";

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
            # gutters = [
            #   "diagnostics"
            #   "line-numbers"
            #   "spacer"
            #   "diff"
            # ];
            file-picker = {
              hidden = false;
            };
            indent-guides = {
              render = true;
              character = "┊";
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
                "file-name"
                "file-modification-indicator"
              ];
              center = [ ];
              right = [
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
