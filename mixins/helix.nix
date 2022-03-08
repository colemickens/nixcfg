{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.helix = {
        enable = true;
        package =
          inputs.helix.outputs.packages.${pkgs.system}.helix;
          #if pkgs.system == "x86_64-linux"
          #then inputs.helix.outputs.packages.${pkgs.system}.helix
          #else pkgs.helix;
        settings = {
          # theme = "default"; # cute but not enough contrast
          # theme = "base16_default_dark"; # unreadable popup text
          #theme = "dark_plus";
          theme = "gruvbox";

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
