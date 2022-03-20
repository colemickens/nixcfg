{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
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
