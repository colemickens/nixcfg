{ pkgs, config, inputs, ... }:

{
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
