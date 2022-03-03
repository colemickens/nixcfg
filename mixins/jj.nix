{ pkgs, config, inputs, ... }:

{
  config = {
    documentation.enable = pkgs.lib.mkForce true; # for the demo
    documentation.man.enable = pkgs.lib.mkForce true; # for the demo
    home-manager.users.cole = { pkgs, ... }: {
      programs.jj = {
        enable = true;
        package = inputs.jj.outputs.packages.${pkgs.system}.jujutsu;
        settings = {
          user = {
            name = "Cole Mickens";
            email = "cole.mickens@gmail.com";
          };
        };
      };
    };
  };
}
