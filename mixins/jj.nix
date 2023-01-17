{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.jj = {
        enable = true;
        package = inputs.jj.outputs.packages.${pkgs.stdenv.hostPlatform.system}.jujutsu;
        settings = {
          user = {
            name = "Cole Mickens";
            email = "cole.mickens@gmail.com";
          };
          ui = {
            color = "always";
          };
        };
      };
    };
  };
}
