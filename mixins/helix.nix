{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.helix = {
        enable = true;
        package =
          inputs.helix.outputs.packages.${pkgs.system}.helix;
        settings = {
          theme = "dark_plus";
          #theme = "gruvbox";
          #theme = "base16_terminal";

          editor = {
            cursor-shape = {
              normal = "block";
              insert = "bar";
              select = "underline";
            };
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
