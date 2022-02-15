{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.helix = {
        enable = true;
        package =
          #if pkgs.system == "x86_64-linux"
          #then inputs.helix.outputs.packages.${pkgs.system}.helix
          #else pkgs.helix;
          inputs.helix.outputs.packages.${pkgs.system}.helix;
        settings = {
          theme = "base16";
        };
      };
    };
  };
}
