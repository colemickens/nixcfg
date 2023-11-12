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
    # this didn't work any better for cross-compilation
    # nixpkgs.overlays = [
    #   inputs.helix.outputs.overlays.default
    # ];
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
          # theme = "ayu_evolve";
          # theme = "everblush";

          # like, but no constrast on bar for open file
          # theme = "ayu_dark";

          theme = "dark_plus";

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
