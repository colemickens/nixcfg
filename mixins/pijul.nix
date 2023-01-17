{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      programs.pijul = {
        enable = true;
        #package = inputs.jj.outputs.packages.${pkgs.stdenv.hostPlatform.system}.jj;
        settings = {
          user = {
            name = "colemickens";
            full_name = "Cole Mickens";
            email = "cole.mickens@gmail.com";
          };
        };
      };
    };
  };
}
