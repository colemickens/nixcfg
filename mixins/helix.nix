{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.helix = {
        enable = true;
        package = inputs.helix.outputs.packages.${pkgs.system}.helix;
        settings = {
          theme = "base16";
        };
      };
    };
  };
}
