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
        programs.jujutsu = {
          enable = true;
          package = inputs.jj.outputs.packages.${pkgs.stdenv.hostPlatform.system}.jujutsu;
          settings = {
            user = {
              name = "Cole Mickens";
              email = "cole.mickens@gmail.com";
            };
            core = {
              # fsmonitor = "watchman"; NOOOOO caused serious confusing issues
            };
            signing = {
              behavior = "drop";
              backend = "gpg";
            };
            git = {
              sign-on-push = true;
              # abandon-unreachable-commits = true; # ? TODO: not sure if better to do manually
            };
            ui = {
              log-synthetic-elided-nodes = true;
              # pager = ":builtin";
            };
            template-aliases = {
            };
            "--scope" = [
              {
                "--when.repositories" = [ "~/work/" ];
                user.email = "cole.mickens@determinate.systems";
                gpg.key = config.sops.secrets."github-signingkey-detsys".path;
              }
            ];
          };
        };
      };
  };
}
