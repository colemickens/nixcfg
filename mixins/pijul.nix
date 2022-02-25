{ pkgs, config, inputs, ... }:

{
  config = {
    home-manager.users.cole = { pkgs, ... }: {
      imports = [
        ../modules-hm/pijul.nix
      ];
      programs.pijul = {
        enable = true;
        #package = inputs.jj.outputs.packages.${pkgs.system}.jj;
        package = pkgs.pijul;
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
