{ pkgs, config, inputs, ... }:

let
  rust_debug_adapter = "codelldb";
in {
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.helix = {
        # lol wut it's broken on aarch64?
        enable = (pkgs.system == "x86_64-linux");
        package =
          if pkgs.system == "x86_64-linux"
          then inputs.helix.outputs.packages.${pkgs.system}.helix
          else pkgs.helix;
          #inputs.helix.outputs.packages.${pkgs.system}.helix;
        # languages = [
        #   {
        #     name = "rust";
        #     debugger = {
        #       name = "codelldb";
        #       transport = "tcp";
        #       port-arg = "--port {}";
        #       command = rust_debug_adapter;

        #       templates = [
        #         {
        #           name = "binary";
        #           request = "launch";
        #           completion = [ { name = "binary"; completion = "filename"; } ];
        #           args = { program = "{0}"; };
        #         }
        #         # {
        #         #   name = "binary (terminal)";
        #         #   request = "launch";
        #         #   completion = [ { name = "binary"; completion = "filename"; } ];
        #         #   args = { program = "{0}"; runInTerminal = true; };
        #         # }
        #         # {
        #         #   name = "attach";
        #         #   request = "attach";
        #         #   completion = [ "pid" ];
        #         #   args = { pid = "{0}"; };
        #         # }
        #         # {
        #         # name = "gdbserver attach";
        #         #   request = "attach";
        #         #   completion = [
        #         #     { name = "lldb connect url"; default = "connect://localhost:3333"; }
        #         #     { name = "file"; completion = "filename"; }
        #         #     "pid"
        #         #   ];
        #         #   args = {
        #         #     attachCommands = [
        #         #       "platform select remote-gdb-server"
        #         #       "platform connect {0}"
        #         #       "file {1}"
        #         #       "attach {2}"
        #         #     ];
        #         #   };
        #         # }
        #       ];
        #     };
        #   }
        # ];
        settings = {
          # theme = "default"; # cute but not enough contrast
          # theme = "base16_default_dark"; # unreadable popup text
          theme = "monokai_pro_octagon";

          editor = {
            true-color = true;
          };
          lsp = {
            display-messages = true;
          };
        };
      };
    };
  };
}
