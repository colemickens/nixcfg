{
  pkgs,
  config,
  inputs,
  ...
}:

{
  config = {
    home-manager.users.cole =
      { pkgs, ... }:
      {
        home.packages = with pkgs; [
          lazyjj
        ];
        programs.jj = {
          enable = true;
          package = inputs.jj.outputs.packages.${pkgs.stdenv.hostPlatform.system}.jujutsu;
          settings = {
            user = {
              name = "Cole Mickens";
              email = "cole.mickens@gmail.com";
            };
            core = {
              fsmonitor = "watchman";
            };
            git = {
              # abandon-unreachable-commits = true; # ? TODO: not sure if better to do manually
            };
            ui = {
              log-synthetic-elided-nodes = true;
              # pager = ":builtin";
            };
            template-aliases = {
            };
          };
        };
      };
  };
}
