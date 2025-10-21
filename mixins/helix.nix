{
  pkgs,
  config,
  inputs,
  ...
}:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
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
        xdg.configFile."helix/languages.toml".text =
          let
          in
          # lldbRustcScript = pkgs.writeShellScript "lldb-rustc-prelude.py" ''
          #   import subprocess
          #   import pathlib
          #   import lldb
          #   # determine the sysroot for the active rust interpreter
          #   rustlib_etc = pathlib.Path(subprocess.getoutput('rustc --print sysroot')) / 'lib' / 'rustlib' / 'etc'
          #   if not rustlib_etc.exists():
          #       raise RuntimeError('Unable to determine rustc sysroot')
          #   # load lldb_lookup.py and execute lldb_commands with the correct path
          #   lldb.debugger.HandleCommand(f"""command script import "{rustlib_etc / 'lldb_lookup.py'}" """)
          #   lldb.debugger.HandleCommand(f"""command source -s 0 "{rustlib_etc / 'lldb_commands'}" """)
          # '';
          ''
            [language-server.nu-lsp]
            command = "nu"
            args = [ "--lsp" ]

            [[language]]
            name = "nix"
            auto-format = false
            formatter = { command = "nixfmt-rfc-style" }
            language-servers = [ "nixd" ] # TESTING

            [[language]]
            name = "nu"
            language-servers = [ "nu-lsp" ]
          '';

        # [[language]]
        # name = "rust"

        # [language.debugger]
        # name = "lldb-vscode"
        # transport = "stdio"
        # command = "lldb-vscode"
        #   [[langauge.debugger.templates]]
        #   name = "binary"
        #   request = "launch"
        #   completion = [ { name = "binary", completion = "filename" } ]
        #   args = { program = "{0}", initCommands = [ "command script import ${lldbRustcScript}" ] }
        # '';
        programs.helix = {
          enable = true;

          settings = {
            theme = {
              dark = "catppuccin_mocha";
              light = "catppuccin_latte";
            };

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
              rulers = [
                80
                120
              ];
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
